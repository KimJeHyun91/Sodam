package com.sodam.util;

import java.security.Key;
import java.util.Date;

import org.springframework.stereotype.Component;

import io.github.cdimascio.dotenv.Dotenv;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtUtil {

    private final Key key;
    private final long DEFAULT_EXPIRATION = 1000 * 60 * 10; // 10분

    public JwtUtil() {
        // ✅ .env 파일에서 JWT_SECRET 불러오기
        Dotenv dotenv = Dotenv.load();
        String secret = dotenv.get("JWT_SECRET");

        if (secret == null || secret.length() < 32) {
            throw new IllegalArgumentException("❌ JWT_SECRET must be defined in .env and be at least 32 characters.");
        }

        this.key = Keys.hmacShaKeyFor(secret.getBytes());
    }

    // ✅ 이메일 인증용 토큰 생성
    public String generateTokenWithEmail(String email, long expirationMillis) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationMillis))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // ✅ 접속자 인증용 토큰 (id + nickName 포함)
    public String generateTokenWithIdentity(String id, String nickName, long expirationMillis) {
        return Jwts.builder()
                .setSubject("GUEST")
                .claim("id", id)
                .claim("nickName", nickName)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationMillis))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean isValidToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }

    public String extractEmail(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    public String extractId(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().get("id", String.class);
    }

    public String extractNickName(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().get("nickName", String.class);
    }

    public Claims getClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody();
    }
}
