package com.sodam.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.domain.RewardItemDomain;
import com.sodam.domain.UserRewardItemDomain;
import com.sodam.dto.UserRewardItemDto;
import com.sodam.id.UserRewardItemId;
import com.sodam.service.RewardItemService;
import com.sodam.service.UserRewardItemService;

@RestController
@RequestMapping("/reward")
public class RewardController {
	@Autowired
	RewardItemService reward_item_service;
	@Autowired
	UserRewardItemService user_reward_item_service;
	
	@PostMapping("/add_user_reward_item")
	public int add_user_reward(@RequestBody UserRewardItemDto user_reward_item_dto) {
		if(
				user_reward_item_dto.getId()==null||
				user_reward_item_dto.getReward_item_no().equals("")
		) {
			return 1900;
		}
		UserRewardItemId user_reward_item_id=new UserRewardItemId();
		user_reward_item_id.setReward_item_no(user_reward_item_dto.getReward_item_no());
		user_reward_item_id.setId(user_reward_item_dto.getId());
		
		UserRewardItemDomain user_reward_item_domain=new UserRewardItemDomain();
		user_reward_item_domain.setUser_reward_item_id(user_reward_item_id);
		
		UserRewardItemDomain result_user_reward_item=user_reward_item_service.add_user_reward(user_reward_item_domain);
		if(result_user_reward_item!=null) {
			return 1200;
		}
		return 1201;
	}
	
	@GetMapping("/get_user_reward_item_list")
	public List<UserRewardItemDomain> get_user_reward_item_list(){
		return user_reward_item_service.get_user_reward_item_list();
	}
	
	@GetMapping("/get_user_reward_item_id_list")
	public List<UserRewardItemDomain> get_user_reward_item_id_list(@RequestParam("id") String id){
		if(id==null||id.equals("")) {
			return null;
		}
		return user_reward_item_service.get_user_reward_item_id_list(id);
	}
	
	@GetMapping("/get_user_reward_item_object")
	public UserRewardItemDomain get_user_reward_item_object(@RequestBody UserRewardItemDto user_reward_item_dto) {
		if(
				user_reward_item_dto.getId()==null||
				user_reward_item_dto.getReward_item_no()==null||
				user_reward_item_dto.getId().equals("")
		) {
			return null;
		}
		
		UserRewardItemId user_reward_item_id=new UserRewardItemId();
		user_reward_item_id.setId(user_reward_item_dto.getId());
		user_reward_item_id.setReward_item_no(user_reward_item_dto.getReward_item_no());

		Optional<UserRewardItemDomain> result_user_reward_item=user_reward_item_service.get_user_reward_item_object(user_reward_item_id);
		if(result_user_reward_item.isPresent()) {
			return result_user_reward_item.get();
		}
		return null;
	}
	
	@DeleteMapping("/delete_user_reward_item_list")
	public int delete_user_reward_item_list() {
		List<UserRewardItemDomain> result_list=user_reward_item_service.delete_user_reward_item_list();
		if(result_list.isEmpty()) {
			return 1210;
		}
		return 1211;
	}
	
	@DeleteMapping("/delete_user_reward_item_id_list")
	public int delete_user_reward_item_id_list(@RequestParam("id") String id) {
		if(id==null||id.equals("")||!(id instanceof String)) {
			return 1900;
		}
		List<UserRewardItemDomain> result_list=user_reward_item_service.delete_user_reward_item_id_list(id);
		if(result_list.isEmpty()) {
			return 1220;
		}
		return 1221;
	}
	
	@DeleteMapping("/delete_user_reward_item_object")
	public int delete_user_reward_item_object(@RequestBody UserRewardItemDto user_reward_item_dto) {
		if(
				user_reward_item_dto.getId()==null||
				user_reward_item_dto.getId().equals("")||
				user_reward_item_dto.getReward_item_no()==null||
				user_reward_item_dto.getReward_item_no().equals("")				
		) {
			return 1900;
		}
		
		UserRewardItemId user_reward_item_id=new UserRewardItemId();
		user_reward_item_id.setId(user_reward_item_dto.getId());
		user_reward_item_id.setReward_item_no(user_reward_item_dto.getReward_item_no());
		
		Optional<UserRewardItemDomain> result_optional=user_reward_item_service.delete_user_reward_item_object(user_reward_item_id);
		if(result_optional.isEmpty()) {
			return 1230;
		}
		return 1231;
	}
	
	@PostMapping("/add_reward_item")
	public int add_reward_item(@RequestBody RewardItemDomain reward_item_domain) {
		if(
				reward_item_domain.getReward_item_category()==null||
				reward_item_domain.getReward_item_category().equals("")||
				reward_item_domain.getReward_item_name()==null||
				reward_item_domain.getReward_item_name().equals("")||
				reward_item_domain.getReward_item_image_url()==null||
				reward_item_domain.getReward_item_image_url().equals("")||
				reward_item_domain.getReward_item_description()==null||
				reward_item_domain.getReward_item_description().equals("")||
				reward_item_domain.getReward_item_price()==null||
				reward_item_domain.getReward_item_price().equals("")
		) {
			return 1900;
		}
		RewardItemDomain result_reward_item=reward_item_service.add_reward_item(reward_item_domain);
		if(result_reward_item!=null) {
			return 1240;
		}	
		
		return 1241;
	}
	
	@GetMapping("/get_reward_item_list")
	public List<RewardItemDomain> get_reward_item_list(){
		return reward_item_service.get_reward_item_list();
	}
	
	@GetMapping("/get_reward_item_object")
	public RewardItemDomain get_reward_item_object(@RequestParam("reward_item_no") Long reward_item_no) {
		if(reward_item_no==null||reward_item_no.equals("")) {
			return null;
		}
		Optional<RewardItemDomain> result_optional=reward_item_service.get_reward_item_object(reward_item_no);
		if(result_optional.isPresent()) {
			return result_optional.get();
		}
		return null;
	}
	
	@PutMapping("/update_reward_item")
	public int update_reward_item(@RequestBody RewardItemDomain reward_item_domain) {
		if(
				reward_item_domain.getReward_item_no()==null||
				reward_item_domain.getReward_item_no().equals("")
		) {
			return 1900;
		}
		
		Optional<RewardItemDomain> result_optional=reward_item_service.get_reward_item_object(reward_item_domain.getReward_item_no());
		if(result_optional.isEmpty()) {
			return 1252;
		}
		RewardItemDomain temp_reward_item_domain=result_optional.get();
		
		if(reward_item_domain.getReward_item_category()!=null||!reward_item_domain.getReward_item_category().equals("")) {
			if(
					!(reward_item_domain.getReward_item_category().equals('F')||
					reward_item_domain.getReward_item_category().equals('C')||
					reward_item_domain.getReward_item_category().equals('D')||
					reward_item_domain.getReward_item_category().equals('A')||
					reward_item_domain.getReward_item_category().equals('T'))
					
			) {
				return 1253;
			}
			temp_reward_item_domain.setReward_item_category(reward_item_domain.getReward_item_category());
		}
		if(reward_item_domain.getReward_item_name()!=null||!reward_item_domain.getReward_item_name().equals("")) {
			temp_reward_item_domain.setReward_item_name(reward_item_domain.getReward_item_name());
		}
		if(reward_item_domain.getReward_item_image_url()!=null||!reward_item_domain.getReward_item_image_url().equals("")) {
			temp_reward_item_domain.setReward_item_image_url(reward_item_domain.getReward_item_image_url());
		}
		if(reward_item_domain.getReward_item_description()!=null||!reward_item_domain.getReward_item_description().equals("")) {
			temp_reward_item_domain.setReward_item_description(reward_item_domain.getReward_item_description());
		}
		if(reward_item_domain.getReward_item_price()!=null||!reward_item_domain.getReward_item_price().equals("")) {
			temp_reward_item_domain.setReward_item_price(reward_item_domain.getReward_item_price());
		}
		
		RewardItemDomain result_reward_item=reward_item_service.update_reward_item(temp_reward_item_domain);
		if(result_reward_item!=null) {
			return 1250;
		}
		
		return 1251;
	}
	
	@DeleteMapping("/delete_reward_item_list")
	public int delete_reward_item_list() {
		List<RewardItemDomain> result_list=reward_item_service.delete_reward_item_list();
		if(result_list.isEmpty()) {
			return 1260;
		}
		return 1261;
	}
	
	@DeleteMapping("/delete_reward_item_object")
	public int delete_reward_item_object(@RequestParam("reward_item_no") Long reward_item_no) {
		if(reward_item_no==null||reward_item_no.equals("")) {
			return 1900;
		}
		Optional<RewardItemDomain> result_optional=reward_item_service.delete_reward_item_object(reward_item_no);
		if(result_optional.isEmpty()) {
			return 1270;
		}
		return 1271;
	}
	
}
