package com.sodam.service;

import java.util.List;
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

	public MemberDomain update(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}

	public List<String> nickname_check(String nickname) {
		return member_repository.nickname_check(nickname);
	}

	public Optional<MemberDomain> delete(String id) {
		member_repository.deleteById(id);;
		return member_repository.findById(id);
	}

}
