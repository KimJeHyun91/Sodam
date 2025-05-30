package com.sodam.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.sodam.domain.MemberDomain;
import com.sodam.dto.LoginResponseDto;
import com.sodam.service.MemberService;
import com.sodam.util.JwtUtil;

@Controller
@RequestMapping("/admin")
public class AdminController {
	@GetMapping("/access")
	@PreAuthorize("hasRole('ADMIN')")
	public String admin() {
		return "admin";
	}
	
	@Autowired
	private JwtUtil jwt_util;
	@Autowired
	private MemberService member_service;
	
    @GetMapping("/get_admin_token")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> get_admin_token(Authentication authentication){
    	if(authentication==null||!authentication.isAuthenticated()) {
    		return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("관리자만 접속이 가능합니다.");
    	}
    	
    	UserDetails user_details=(UserDetails)authentication.getPrincipal();
    	String username=user_details.getUsername();
    	
    	Optional<MemberDomain> member_optional=member_service.get_member_object(username);
    	String nickname=member_optional.map(MemberDomain::getNickname).orElse(null);
    	
    	String jwt=jwt_util.generateToken(username);
    	LoginResponseDto login_response_dto=new LoginResponseDto(jwt, 2000, username, nickname); // 2000:관리자 접속 성공
    	System.out.println("1234 = "+jwt);
    	return ResponseEntity.ok(login_response_dto);
    }
    
}

