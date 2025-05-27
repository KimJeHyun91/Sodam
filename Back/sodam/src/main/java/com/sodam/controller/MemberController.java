package com.sodam.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.domain.MemberDomain;
import com.sodam.service.MemberService;

@RestController
@RequestMapping("/member")
public class MemberController {
	@Autowired
	MemberService member_service;
	@Autowired
	PasswordEncoder password_encoder;
	
	@PostMapping("/add")
	public int add(@RequestBody MemberDomain member_domain) {
		if(
				member_domain.getId()==null||
				member_domain.getId()==""||
				member_domain.getPassword()==null||
				member_domain.getPassword()==""||
				member_domain.getEmail()==null||
				member_domain.getEmail()==""||
				member_domain.getName()==null||
				member_domain.getName()==""||
				member_domain.getBirthday()==null||
				member_domain.getBirthday()==""||
				member_domain.getNickname()==null||
				member_domain.getNickname()==""
				) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isPresent()) {
			return 1003;
		}
		member_domain.setPassword(password_encoder.encode(member_domain.getPassword()));
		MemberDomain result_member=member_service.add(member_domain);
		if(result_member!=null) {
			return 1000;
		}
		return 1001;
	}
	
	@GetMapping("/id_check")
	public int id_check(@RequestBody MemberDomain member_domain) {
		if(member_domain.getId()==null||member_domain.getId().equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isPresent()) {
			return 1003;
		}
		return 1002;
	}
	
}
