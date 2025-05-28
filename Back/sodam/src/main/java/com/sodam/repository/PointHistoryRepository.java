package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.PointHistoryDomain;
import com.sodam.id.PointHistoryId;

@Repository
public interface PointHistoryRepository extends JpaRepository<PointHistoryDomain, PointHistoryId>{
	@Query(value="select * from point_history where point_no=:a", nativeQuery=true)
	List<PointHistoryDomain> get_history_point_no_list(@Param("a") Long point_no);
	
	@Modifying
	@Query(value="delete from point_history where point_no=:a", nativeQuery=true)
	void delete_history_point_no_list(@Param("a") Long point_no);

	@Query("SELECT MAX(ph.point_history_id.point_history_no) FROM POINT_HISTORY ph WHERE ph.point_history_id.point_no = :point_no_param")
	Long findMaxPointHistoryNoByPointNo(@Param("point_no_param") Long point_no);

}
