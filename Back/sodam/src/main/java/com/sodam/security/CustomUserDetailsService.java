package com.sodam.security;

import com.sodam.domain.MemberDomain;
import com.sodam.repository.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String id) throws UsernameNotFoundException {
        MemberDomain member = memberRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("존재하지 않는 사용자입니다: " + id));

        return User.builder()
                .username(member.getId())
                .password(member.getPassword()) // 반드시 암호화되어 있어야 함
                .roles(member.getAuthorization().toString()) // "U", "A" 등을 ROLE로 사용
                .build();
    }
}
