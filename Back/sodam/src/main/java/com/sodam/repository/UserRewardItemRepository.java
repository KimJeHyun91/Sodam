package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sodam.domain.UserRewardItemDomain;
import com.sodam.id.UserRewardItemId;

@Repository
public interface UserRewardItemRepository extends JpaRepository<UserRewardItemDomain, UserRewardItemId>{

}
