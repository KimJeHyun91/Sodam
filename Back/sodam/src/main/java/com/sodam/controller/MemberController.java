package com.sodam.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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
				member_domain.getId().equals("")||
				member_domain.getPassword()==null||
				member_domain.getPassword().equals("")||
				member_domain.getEmail()==null||
				member_domain.getEmail().equals("")||
				member_domain.getName()==null||
				member_domain.getName().equals("")||
				member_domain.getBirthday()==null||
				member_domain.getBirthday().equals("")||
				member_domain.getNickname()==null||
				member_domain.getNickname().equals("")
				) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isPresent()) {
			return 1011;
		}
		member_domain.setPassword(password_encoder.encode(member_domain.getPassword()));
		MemberDomain result_member=member_service.add(member_domain);
		if(result_member!=null) {
			return 1000;
		}
		return 1001;
	}
	
	@GetMapping("/id_check")
	public int id_check(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(id);
		if(result_optional.isPresent()) {
			return 1011;
		}
		return 1010;
	}
	
	@GetMapping("/login")
	public int login(@RequestParam("id") String id, @RequestParam("password") String passwrod) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(id);
		if(result_optional.isEmpty()) {
			return 1010;
		}
		MemberDomain result_domain=result_optional.get();
		boolean result_flag=password_encoder.matches(passwrod, result_domain.getPassword());
		if(result_flag) {
			return 1020;
		}
		return 1021;
	}
	
	@PutMapping("/update")
	public int update(@RequestBody MemberDomain member_domain) {
		if(
				member_domain.getId()==null||
				member_domain.getId().equals("")
				) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isEmpty()) {
			return 1010;
		}
		MemberDomain member=result_optional.get();
		if(member_domain.getPassword()!=null||!member_domain.getPassword().equals("")) {
			member.setPassword(password_encoder.encode(member_domain.getPassword()));
		}
		if(member_domain.getEmail()!=null||!member_domain.getEmail().equals("")) {
			member.setEmail(member_domain.getEmail());
		}
		if(member_domain.getName()!=null||!member_domain.getName().equals("")) {
			member.setName(member_domain.getName());
		}
		if(member_domain.getBirthday()!=null||!member_domain.getBirthday().equals("")) {
			member.setBirthday(member_domain.getBirthday());
		}
		if(member_domain.getNickname()!=null||!member_domain.getNickname().equals("")) {
			List<String> return_string=member_service.nickname_check(member_domain.getNickname());			
			for(int a=0;a<return_string.size();a++) {
				if(a==1) {
					return 1041;
				}
			}
			member.setNickname(member_domain.getNickname());
		}
		MemberDomain result_member=member_service.update(member_domain);
		if(result_member!=null) {
			return 1030;
		}
		return 1031;
	}
	
	@DeleteMapping("/delete")
	public int delete(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_member=member_service.delete(id);
		if(result_member.isEmpty()) {
			return 1050;
		}
		return 1051;
	}
	
}
