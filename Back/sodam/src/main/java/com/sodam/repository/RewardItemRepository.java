package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sodam.domain.RewardItemDomain;

@Repository
public interface RewardItemRepository extends JpaRepository<RewardItemDomain, Long> {

}
