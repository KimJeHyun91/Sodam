package com.sodam.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.MemberDomain;

@Repository
public interface MemberRepository extends JpaRepository<MemberDomain, String>{

	@Query(value="select * from member where nickname=:a", nativeQuery=true)
	Optional<MemberDomain> nickname_check(@Param("a") String nickname);

	@Query(value="select * from member where email=:a", nativeQuery=true)
	Optional<MemberDomain> email_check(@Param("a") String email);

	@Query(value="select * from member where email=:a", nativeQuery=true)
	List<MemberDomain> get_member_email_object(@Param("a") String email);
	

}
