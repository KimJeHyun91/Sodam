package com.sodam.repository;

import com.sodam.domain.MemberDomain;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<MemberDomain, String> {
    boolean existsByEmail(String email); // ✅ 필수!
}
