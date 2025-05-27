package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.UserRewardItemDomain;
import com.sodam.id.UserRewardItemId;

@Repository
public interface UserRewardItemRepository extends JpaRepository<UserRewardItemDomain, UserRewardItemId>{
	@Query(value="select * from user_reward_item where id=:a", nativeQuery=true)
	List<UserRewardItemDomain> get_user_reward_item_id_list(@Param("a") String id);
	
	@Modifying
	@Query(value="delete from user_reward_item where id=:a", nativeQuery=true)
	void delete_user_reward_item_id_list(@Param("a") String id);


}
