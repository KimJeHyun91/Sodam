package com.sodam.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.repository.RewardItemRepository;

@Service
public class RewardItemService {
	@Autowired
	RewardItemRepository reward_item_repository;
}
