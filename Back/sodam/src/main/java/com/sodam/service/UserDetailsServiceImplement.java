package com.sodam.service;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.sodam.domain.MemberDomain;
import com.sodam.repository.MemberRepository; //

@Service
public class UserDetailsServiceImplement implements UserDetailsService{
	@Autowired
	private MemberRepository member_repository;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		MemberDomain member_domain=member_repository.findById(username)
				.orElseThrow(()->new UsernameNotFoundException("해당 접속 이름의 이웃을 찾을 수 없음 : "+username));
		List<GrantedAuthority> authorities=new ArrayList<>();
		if(member_domain.getAuthorization()!=null) {
			if(member_domain.getAuthorization().equals('A')) {
				authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
			}else if(member_domain.getAuthorization().equals('U')) {
				authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
			}
		}else {
			authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
		}
		
		
		
		return new User(member_domain.getId(), member_domain.getPassword(), authorities);
	}
	
}
