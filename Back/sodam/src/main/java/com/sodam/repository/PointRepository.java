package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.PointDomain;

@Repository
public interface PointRepository extends JpaRepository<PointDomain, Long>{

	@Query(value="select * from point where id=:a", nativeQuery=true)
	PointDomain get_info(@Param("a") String id);

}
