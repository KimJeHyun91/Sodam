package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sodam.domain.UserImageDomain;

@Repository
public interface UserImageRepository extends JpaRepository<UserImageDomain, String>{
	
}
