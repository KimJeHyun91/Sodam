package com.sodam.service;

import java.util.List;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.RewardItemDomain;
import com.sodam.repository.RewardItemRepository;

@Service
public class RewardItemService {
	@Autowired
	RewardItemRepository reward_item_repository;

	@Transactional
	public RewardItemDomain add_reward_item(RewardItemDomain reward_item_domain) {
		return reward_item_repository.save(reward_item_domain);
	}

	@Transactional(readOnly = true)
	public List<RewardItemDomain> get_reward_item_list() {
		return reward_item_repository.findAll();
	}

	@Transactional(readOnly = true)
	public Optional<RewardItemDomain> get_reward_item_object(Long reward_item_no) {
		return reward_item_repository.findById(reward_item_no);
	}

	@Transactional
	public RewardItemDomain update_reward_item(RewardItemDomain temp_reward_item_domain) {
		return reward_item_repository.save(temp_reward_item_domain);
	}

	@Transactional
	public List<RewardItemDomain> delete_reward_item_list() {
		reward_item_repository.deleteAll();
		return reward_item_repository.findAll();
	}

	@Transactional
	public Optional<RewardItemDomain> delete_reward_item_object(Long reward_item_no) {
		reward_item_repository.deleteById(reward_item_no);
		return reward_item_repository.findById(reward_item_no);
	}
}
