package com.sodam.controller;


import com.sodam.domain.MemberDomain;
import com.sodam.service.EmailService;
import com.sodam.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;


@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final EmailService emailService;

    private final MemberService memberService;
    private final PasswordEncoder passwordEncoder;

    
    @PostMapping("/send-code-signup")
    public ResponseEntity<?> sendCodeForSignup(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "이메일은 필수입니다.")
            );
        }

        emailService.sendVerificationCode(email);
        return ResponseEntity.ok(Map.of("status", "success", "message", "인증번호가 전송되었습니다."));
    }

    
    @PostMapping("/send-code-find-id")
    public ResponseEntity<?> sendCodeForFindId(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "이메일은 필수입니다.")
            );
        }

        if (memberService.email_check(email).isEmpty()) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "등록되지 않은 이메일입니다.")
            );
        }

        emailService.sendVerificationCode(email);
        return ResponseEntity.ok(Map.of("status", "success", "message", "인증번호가 전송되었습니다."));
    }

    
    @PostMapping("/send-code-reset-pw")
    public ResponseEntity<?> sendCodeForResetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "이메일은 필수입니다.")
            );
        }

        if (memberService.email_check(email).isEmpty()) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "등록되지 않은 이메일입니다.")
            );
        }

        emailService.sendVerificationCode(email);
        return ResponseEntity.ok(Map.of("status", "success", "message", "인증번호가 전송되었습니다."));
    }

    

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");


        if (email == null || code == null) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "이메일과 인증코드를 모두 입력하세요.")
            );
        }

        if (!emailService.codeExists(email)) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "인증번호가 만료되었습니다.")
            );
        }

        if (!emailService.isCodeCorrect(email, code)) {
            return ResponseEntity.badRequest().body(
                Map.of("status", "fail", "message", "인증번호가 일치하지 않습니다.")
            );
        }

        return ResponseEntity.ok(Map.of("status", "success"));
    }

    
   
    @PostMapping("/reset-password")
    public ResponseEntity<Integer> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");
        String newPassword = request.get("newPassword");

        if (email == null || code == null || newPassword == null) {
            return ResponseEntity.ok(1900); 
        }

        if (!emailService.verifyCode(email, code)) {
            return ResponseEntity.ok(1051); 
        }

        Optional<MemberDomain> optional = memberService.email_check(email);
        if (optional.isEmpty()) {
            return ResponseEntity.ok(1010); 
        }

        MemberDomain member = optional.get();

        if (passwordEncoder.matches(newPassword, member.getPassword())) {
            return ResponseEntity.ok(1052); 
        }

        member.setPassword(passwordEncoder.encode(newPassword));
        MemberDomain updated = memberService.update(member);

        return ResponseEntity.ok(updated != null ? 1050 : 1051); 

    }
}