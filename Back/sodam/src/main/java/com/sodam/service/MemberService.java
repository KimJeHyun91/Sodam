package com.sodam.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.MemberDomain;
import com.sodam.repository.MemberRepository;

@Service
public class MemberService {
	@Autowired
	MemberRepository member_repository;
	
	public Optional<MemberDomain> id_check(String id) {
		return member_repository.findById(id);
	}

	public MemberDomain add(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}

}
