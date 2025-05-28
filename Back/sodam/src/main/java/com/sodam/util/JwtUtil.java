package com.sodam.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys; // Keys 클래스 import
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct; // PostConstruct import
import java.nio.charset.StandardCharsets; // StandardCharsets import
import java.security.Key; // Key 인터페이스 import
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secretString; // application.properties에서 문자열로 비밀키를 받음

    private Key SECRET_KEY; // Key 타입으로 변경

    private final long TOKEN_VALIDITY_SECONDS = 3 * 60 * 60; // 토큰 유효 시간: 3시간

    // 의존성 주입 후 비밀키를 Key 객체로 변환
    @PostConstruct
    public void init() {
        // SECRET_KEY 문자열을 바이트 배열로 변환하고, 이를 사용하여 HMAC-SHA 키 생성
        // HS256 알고리즘은 최소 256비트(32바이트)의 키 길이를 권장합니다.
        // secretString의 길이가 32바이트 미만이면 패딩하거나, 충분히 긴 키를 사용해야 합니다.
        byte[] keyBytes = secretString.getBytes(StandardCharsets.UTF_8);
        this.SECRET_KEY = Keys.hmacShaKeyFor(keyBytes);
    }

    // 토큰에서 사용자 이름(ID) 추출
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // 토큰에서 만료 시간 추출
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // 토큰에서 특정 클레임 추출
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // 토큰에서 모든 클레임 추출
    private Claims extractAllClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(SECRET_KEY)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            return null;
        }
    }

    // 토큰 만료 여부 확인
    private Boolean isTokenExpired(String token) {
        try {
            return extractExpiration(token).before(new Date());
        } catch (ExpiredJwtException e) { // 만료된 토큰에서 만료 시간을 추출하려 할 때도 ExpiredJwtException 발생 가능
            return true;
        }
    }
    
    // UserDetails 객체를 사용하여 토큰 생성
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername());
    }

    // 사용자 이름(ID) 문자열만으로 토큰 생성
    public String generateToken(String username) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, username);
    }

    // 토큰 생성 로직
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + TOKEN_VALIDITY_SECONDS * 1000))
                .signWith(SECRET_KEY, SignatureAlgorithm.HS256)
                .compact();
    }

    // 토큰 유효성 검사 (UserDetails 사용)
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    // 토큰 유효성 검사 (사용자 이름 문자열 사용)
    public Boolean validateToken(String token, String username) {
        try {
            final String extractedUsername = extractUsername(token);
            return (extractedUsername.equals(username) && !isTokenExpired(token));
        } catch (Exception e) { // 토큰 파싱 실패 등 다양한 예외 처리
            return false;
        }
    }
}