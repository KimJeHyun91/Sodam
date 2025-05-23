package com.sodam.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.service.RewardItemService;
import com.sodam.service.UserRewardItemService;

@RestController
@RequestMapping("/reward")
public class RewardController {
	@Autowired
	RewardItemService reward_item_service;
	@Autowired
	UserRewardItemService user_reward_item_service;
	
	
}
