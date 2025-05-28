package com.sodam.controller;

import com.sodam.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final EmailService emailService;

    @PostMapping("/send-code")
    public ResponseEntity<?> sendCode(@RequestParam String email) {
        emailService.sendVerificationCode(email);
        return ResponseEntity.ok("인증번호가 전송되었습니다.");
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestParam String email, @RequestParam String code) {
        boolean success = emailService.verifyCode(email, code);
        return success ?
                ResponseEntity.ok("인증 성공") :
                ResponseEntity.badRequest().body("인증 실패: 코드가 일치하지 않거나 만료됨");
    }
}
