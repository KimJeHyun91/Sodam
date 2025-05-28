package com.sodam.controller;

import com.sodam.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final EmailService emailService;

    @PostMapping("/send-code")
    public ResponseEntity<?> sendCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body("이메일은 필수입니다.");
        }

        emailService.sendVerificationCode(email);
        return ResponseEntity.ok("인증번호가 전송되었습니다.");
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");

        if (email == null || code == null) {
            return ResponseEntity.badRequest().body("이메일과 인증코드를 모두 입력하세요.");
        }

        boolean success = emailService.verifyCode(email, code);
        return success ?
                ResponseEntity.ok("인증 성공") :
                ResponseEntity.badRequest().body("인증 실패: 코드가 일치하지 않거나 만료됨");
    }
}
