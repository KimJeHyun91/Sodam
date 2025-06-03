package com.sodam.handler;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sodam.domain.MemberDomain;
import com.sodam.dto.LoginResponseDto; // LoginResponseDto 사용
import com.sodam.service.MemberService;
import com.sodam.util.JwtUtil; // JwtUtil 사용
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Optional;

@Component
public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler {
	@Autowired
	private JwtUtil jwt_util;
	@Autowired
	private ObjectMapper object_mapper;
	@Autowired
	MemberService member_service;
	
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {
		UserDetails user_details=(UserDetails)authentication.getPrincipal();
		String username=user_details.getUsername();
		Optional<MemberDomain> member_optional = member_service.get_member_object(username);
		String nickname = member_optional.map(MemberDomain::getNickname).orElse(null);
		
		String jwt=jwt_util.generateToken(username);
		
		LoginResponseDto login_response_dto=new LoginResponseDto(jwt, 1020, username, nickname);
		
		response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(object_mapper.writeValueAsString(login_response_dto));
        response.getWriter().flush();
	}
	
	
}
