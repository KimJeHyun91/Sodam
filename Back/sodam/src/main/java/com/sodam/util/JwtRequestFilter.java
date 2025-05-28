package com.sodam.util;

import com.sodam.service.UserDetailsServiceImplement;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter; // 모든 요청에 대해 한 번만 실행되도록 보장

import java.io.IOException;

@Component
public class JwtRequestFilter extends OncePerRequestFilter{

	private static final Logger logger=LoggerFactory.getLogger(JwtRequestFilter.class);
	
	@Autowired
	private UserDetailsServiceImplement user_detail_service;
	
	@Autowired
	private JwtUtil jwt_util;
	
	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filter_chain)
			throws ServletException, IOException {
		final String authorization_header=request.getHeader("Authorization");
		
		String username=null;
		String jwt=null;
		
		if(authorization_header!=null&&authorization_header.startsWith("Bearer ")) {
			jwt=authorization_header.substring(7);
			try {
				username=jwt_util.extractUsername(jwt);
			}catch(IllegalArgumentException e) {
				logger.warn("JWT Token 내용이 잘못되었습니다.");
			}catch(ExpiredJwtException e) {
				logger.warn("JWT Token이 만료되었습니다.");
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				return;
			}catch(Exception e) {
				logger.warn("JWT Token 검증 중 알 수 없는 오류 발생 : {}", e.getMessage());
			}
		}else {
			logger.warn("JWT Token이 없거나 'Bearer '로 시작하지 않습니다.");
		}
		
		if(username!=null&&SecurityContextHolder.getContext().getAuthentication()==null) {
			UserDetails user_details=this.user_detail_service.loadUserByUsername(username);
			
			if(jwt_util.validateToken(jwt, user_details.getUsername())) {
				UsernamePasswordAuthenticationToken username_password_authentication_token=
						new UsernamePasswordAuthenticationToken(user_details, null, user_details.getAuthorities());
				username_password_authentication_token
					.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
				SecurityContextHolder.getContext().setAuthentication(username_password_authentication_token);
			}
		}
		
		filter_chain.doFilter(request, response);
		
	}
	
	
}
