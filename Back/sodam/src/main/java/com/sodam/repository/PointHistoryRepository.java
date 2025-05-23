package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.PointHistoryDomain;
import com.sodam.id.PointHistoryId;

@Repository
public interface PointHistoryRepository extends JpaRepository<PointHistoryDomain, PointHistoryId>{
	@Query(value="select * from point_history where point_no=:a", nativeQuery=true)
	List<PointHistoryDomain> get_history_list(@Param("a") Long point_no);

	@Query(value="delete from point_history where point_no=:a", nativeQuery=true)
	void delete_history_all(@Param("a") Long point_no);

}
