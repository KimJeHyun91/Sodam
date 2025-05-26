package com.sodam.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sodam.repository.MemberRepository;
import com.sodam.service.EmailService;
import com.sodam.util.JwtUtil;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final JwtUtil jwtUtil;
    private final EmailService emailService;
    private final MemberRepository memberRepository;

    public AuthController(JwtUtil jwtUtil, EmailService emailService, MemberRepository memberRepository) {
        this.jwtUtil = jwtUtil;
        this.emailService = emailService;
        this.memberRepository = memberRepository;
    }

    // ✅ 이메일 인증 토큰 발급
    @PostMapping("/email-token")
    public ResponseEntity<?> sendEmailToken(@RequestParam String email) {
        if (!memberRepository.existsByEmail(email)) {
            return ResponseEntity.badRequest().body("이메일이 존재하지 않음");
        }
        String token = jwtUtil.generateTokenWithEmail(email, 10 * 60 * 1000); // 10분 유효
        emailService.send(email, "이메일 인증", "이메일 인증 토큰: " + token);
        return ResponseEntity.ok("토큰이 이메일로 전송되었습니다.");
    }

    // ✅ 이메일 인증 토큰 검증
    @PostMapping("/verify-token")
    public ResponseEntity<?> verifyEmailToken(@RequestParam String token) {
        if (!jwtUtil.isValidToken(token)) {
            return ResponseEntity.badRequest().body("❌ 유효하지 않은 토큰입니다.");
        }
        String email = jwtUtil.extractEmail(token);
        return ResponseEntity.ok("✅ 확인되었습니다: " + email);
    }

    // ✅ 접속자용 토큰 발급 (ID + nickName)
    @PostMapping("/guest-token")
    public ResponseEntity<?> issueGuestToken(@RequestParam String id, @RequestParam String nickName) {
        String token = jwtUtil.generateTokenWithIdentity(id, nickName, 1000 * 60 * 60 * 24); // 24시간 유효
        return ResponseEntity.ok(Map.of("token", token));
    }
}
