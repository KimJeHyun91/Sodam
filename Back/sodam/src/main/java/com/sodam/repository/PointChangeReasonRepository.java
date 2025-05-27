package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sodam.domain.PointChangeReasonDomain;

@Repository
public interface PointChangeReasonRepository extends JpaRepository<PointChangeReasonDomain, String>{

}
