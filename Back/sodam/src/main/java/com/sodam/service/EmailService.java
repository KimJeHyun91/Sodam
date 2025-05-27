package com.sodam.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    // 인증번호 임시 저장 (운영 시 Redis로 교체 가능)
    private final Map<String, String> emailAuthCodes = new HashMap<>();

    @Value("${spring.mail.username}")
    private String fromEmail;

    public String sendVerificationCode(String toEmail) {
        String code = generateRandomCode();

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("소담 - 이메일 인증번호");
            helper.setText("<h3>이메일 인증번호는 <strong>" + code + "</strong> 입니다.</h3>", true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("이메일 전송 실패", e);
        }

        emailAuthCodes.put(toEmail, code);
        return code;
    }

    public boolean verifyCode(String email, String code) {
        return code.equals(emailAuthCodes.get(email));
    }

    private String generateRandomCode() {
        return String.format("%06d", new Random().nextInt(1000000));
    }
}
