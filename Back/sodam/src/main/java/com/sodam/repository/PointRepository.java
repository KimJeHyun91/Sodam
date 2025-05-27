package com.sodam.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.PointDomain;

@Repository
public interface PointRepository extends JpaRepository<PointDomain, Long>{

	@Query(value="select * from point where id=:id_param", nativeQuery=true)
	Optional<PointDomain> get_info_id_object(@Param("id_param") String id);


}
