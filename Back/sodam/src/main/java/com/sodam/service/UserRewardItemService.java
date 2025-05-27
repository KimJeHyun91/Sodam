package com.sodam.service;

import java.util.List;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.UserRewardItemDomain;
import com.sodam.id.UserRewardItemId;
import com.sodam.repository.UserRewardItemRepository;

@Service
public class UserRewardItemService {
	@Autowired
	UserRewardItemRepository user_reward_item_repository;
	
	@Transactional
	public UserRewardItemDomain add_user_reward(UserRewardItemDomain user_reward_item_domain) {
		return user_reward_item_repository.save(user_reward_item_domain);
	}

	@Transactional(readOnly = true)
	public List<UserRewardItemDomain> get_user_reward_item_list() {
		return user_reward_item_repository.findAll();
	}

	@Transactional(readOnly = true)
	public List<UserRewardItemDomain> get_user_reward_item_id_list(String id) {
		return user_reward_item_repository.get_user_reward_item_id_list(id);
	}

	@Transactional(readOnly = true)
	public Optional<UserRewardItemDomain> get_user_reward_item_object(UserRewardItemId user_reward_item_id) {
		return user_reward_item_repository.findById(user_reward_item_id);
	}

	@Transactional
	public List<UserRewardItemDomain> delete_user_reward_item_list() {
		user_reward_item_repository.deleteAll();
		return user_reward_item_repository.findAll();
	}

	@Transactional
	public List<UserRewardItemDomain> delete_user_reward_item_id_list(String id) {
		user_reward_item_repository.delete_user_reward_item_id_list(id);
		return user_reward_item_repository.get_user_reward_item_id_list(id);
	}

	@Transactional
	public Optional<UserRewardItemDomain> delete_user_reward_item_object(UserRewardItemId user_reward_item_id) {
		user_reward_item_repository.deleteById(user_reward_item_id);
		return user_reward_item_repository.findById(user_reward_item_id);
	}

}
