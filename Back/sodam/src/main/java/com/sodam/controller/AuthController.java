package com.sodam.controller;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Qualifier;
import com.sodam.domain.MemberDomain;
import com.sodam.dto.CodeVerificationDto;
import com.sodam.dto.EmailDto;
import com.sodam.dto.LoginRequest;
import com.sodam.dto.LoginResponse;
import com.sodam.dto.PasswordResetDto;
import com.sodam.security.JwtTokenProvider;
import com.sodam.service.MemberService;


import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final JavaMailSender mailSender;
    private final MemberService memberService;
    private final PasswordEncoder passwordEncoder;

    // 메모리 내 임시 인증코드 저장
    private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();

    @Autowired
    public AuthController(
        AuthenticationManager authenticationManager,
        JwtTokenProvider tokenProvider,
        JavaMailSender mailSender,
        @Qualifier("passwordEncoder") PasswordEncoder passwordEncoder,  // 명시
        MemberService memberService
    ) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
        this.mailSender = mailSender;
        this.passwordEncoder = passwordEncoder;
        this.memberService = memberService;
    }

    // ✅ 로그인 - JWT 발급
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getId(), request.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = tokenProvider.generateToken(userDetails.getUsername());

            return ResponseEntity.ok(new LoginResponse(token));
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(401).body("아이디 또는 비밀번호가 올바르지 않습니다.");
        }
    }

    // ✅ 이메일로 인증번호 전송
    @PostMapping("/send-code")
    public ResponseEntity<?> sendVerificationCode(@RequestBody EmailDto request) {
        String code = String.valueOf((int)(Math.random() * 900000) + 100000); // 6자리 숫자
        verificationCodes.put(request.getEmail(), code);

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getEmail());
        message.setSubject("Sodam 인증번호입니다");
        message.setText("인증번호: " + code);

        try {
            mailSender.send(message);
            return ResponseEntity.ok("인증번호가 전송되었습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("메일 전송에 실패했습니다.");
        }
    }

    // ✅ 인증번호 확인
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody CodeVerificationDto dto) {
        String expectedCode = verificationCodes.get(dto.getEmail());
        if (expectedCode != null && expectedCode.equals(dto.getCode())) {
            verificationCodes.remove(dto.getEmail()); // 성공 후 삭제
            return ResponseEntity.ok("인증 성공");
        } else {
            return ResponseEntity.status(400).body("인증 실패");
        }
    }

    // ✅ 인증 후 비밀번호 재설정
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody PasswordResetDto dto) {
        Optional<MemberDomain> memberOpt = memberService.email_check(dto.getEmail());

        if (memberOpt.isPresent()) {
            MemberDomain member = memberOpt.get();
            member.setPassword(passwordEncoder.encode(dto.getNewPassword())); // 암호화
            memberService.update(member);
            return ResponseEntity.ok("비밀번호가 성공적으로 변경되었습니다.");
        } else {
            return ResponseEntity.status(404).body("해당 이메일을 찾을 수 없습니다.");
        }
    }
}
