package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.MemberDomain;

@Repository
public interface MemberRepository extends JpaRepository<MemberDomain, String>{

	@Query(value="select nickname from member where nickname=:a", nativeQuery=true)
	List<String> nickname_check(@Param("a") String nickname);

}
