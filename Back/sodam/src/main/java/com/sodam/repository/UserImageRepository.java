package com.sodam.repository;

import java.time.LocalDateTime;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.UserImageDomain;

@Repository
public interface UserImageRepository extends JpaRepository<UserImageDomain, String>{
	
	@Query(value="insert into USER_IMAGE values(:a, :b, :c, :d)", nativeQuery=true)
	UserImageDomain add_image(@Param("a") String id,@Param("b") byte[] bytea,@Param("c") LocalDateTime created_date,@Param("d") LocalDateTime last_modified_date);
}


