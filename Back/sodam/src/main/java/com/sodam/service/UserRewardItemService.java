package com.sodam.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.repository.UserRewardItemRepository;

@Service
public class UserRewardItemService {
	@Autowired
	UserRewardItemRepository user_reward_item_repository;
}
