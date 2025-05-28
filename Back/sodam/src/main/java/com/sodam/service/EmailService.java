package com.sodam.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    // 이메일: 인증코드 + 만료시간 저장
    private final Map<String, AuthCodeEntry> authCodeStore = new ConcurrentHashMap<>();
    private static final long EXPIRE_TIME = 3 * 60 * 1000; // 3분

    private static class AuthCodeEntry {
        String code;
        long expiresAt;

        AuthCodeEntry(String code, long expiresAt) {
            this.code = code;
            this.expiresAt = expiresAt;
        }
    }

    public void sendVerificationCode(String email) {
        String code = String.format("%06d", new Random().nextInt(999999));
        long expiresAt = System.currentTimeMillis() + EXPIRE_TIME;

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(email);
            helper.setFrom(fromEmail);
            helper.setSubject("소담 - 이메일 인증번호");
            helper.setText("<h3>인증번호: <strong>" + code + "</strong><br/>유효시간: 3분</h3>", true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("이메일 전송 실패", e);
        }

        authCodeStore.put(email, new AuthCodeEntry(code, expiresAt));
    }

    public boolean verifyCode(String email, String inputCode) {
        AuthCodeEntry entry = authCodeStore.get(email);
        if (entry == null || System.currentTimeMillis() > entry.expiresAt) {
            return false;
        }
        return entry.code.equals(inputCode);
    }
}
