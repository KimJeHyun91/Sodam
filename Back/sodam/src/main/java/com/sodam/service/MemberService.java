package com.sodam.service;

import java.util.List;

import java.util.Optional;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.MemberDomain;
import com.sodam.repository.MemberRepository;


@Service
public class MemberService {
	@Autowired
	MemberRepository member_repository;
	
	@Transactional(readOnly = true)
	public Optional<MemberDomain> id_check(String id) {
		return member_repository.findById(id);
	}

	@Transactional
	public MemberDomain add(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}
	
	@Transactional
	public MemberDomain update(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> nickname_check(String nickname) {
		return member_repository.nickname_check(nickname);
	}
	
	@Transactional
	public Optional<MemberDomain> delete(String id) {
		member_repository.deleteById(id);
		return member_repository.findById(id);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> get_member_object(String id) {
		return member_repository.findById(id);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> email_check(String email) {
		return member_repository.email_check(email);
	}

	@Transactional(readOnly = true)
	public List<MemberDomain> get_member_list() {
		return member_repository.findAll();
	}
	
	@Transactional(readOnly = true)
	public List<MemberDomain> get_member_email_object(String email) {
		return member_repository.get_member_email_object(email);
	}

}