package com.sodam.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.domain.BlockedDeviceDomain;
import com.sodam.domain.BluetoothConnectedDeviceDomain;
import com.sodam.domain.MemberDomain;
import com.sodam.domain.PointDomain;
import com.sodam.domain.PointHistoryDomain;
import com.sodam.domain.UserRewardItemDomain;
import com.sodam.service.BlockedDeviceService;
import com.sodam.service.BluetoothConnectedDeviceService;
import com.sodam.service.MemberService;
import com.sodam.service.PointHistoryService;
import com.sodam.service.PointService;
import com.sodam.service.UserRewardItemService;

import jakarta.transaction.Transactional;

@RestController
@RequestMapping("/member")
public class MemberController {
	@Autowired
	MemberService member_service;
	@Autowired
	PasswordEncoder password_encoder;
	@Autowired
	PointService point_service;
	@Autowired
	PointHistoryService point_history_service;
	@Autowired
	BluetoothConnectedDeviceService bluetooth_connected_device_service;
	@Autowired
	BlockedDeviceService blocked_device_service;
	@Autowired
	UserRewardItemService user_reward_item_service;
	
	@Transactional
	@PostMapping("/add")
	public int add(@RequestBody MemberDomain member_domain) {
		if(
				member_domain.getId()==null||
				member_domain.getId().equals("")||
				member_domain.getPassword()==null||
				member_domain.getPassword().equals("")||
				member_domain.getEmail()==null||
				member_domain.getEmail().equals("")||
				member_domain.getName()==null||
				member_domain.getName().equals("")||
				member_domain.getBirthday()==null||
				member_domain.getBirthday().equals("")||
				member_domain.getNickname()==null||
				member_domain.getNickname().equals("")
				) {
			return 1900;
		}
		member_domain.setAuthorization('U');
		int member_flag=0;
		int point_flag=0;
		
		// 이웃 테이블 생성
		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isPresent()) {
			return 1011;
		}
		member_domain.setPassword(password_encoder.encode(member_domain.getPassword()));
		MemberDomain result_member=member_service.add(member_domain);
		if(result_member!=null) {
			member_flag=1;
			
			// 포인트 테이블 생성
			PointDomain point_domain=new PointDomain();
			point_domain.setId(result_member.getId());
			point_domain.setCurrent_point(0L);
			PointDomain result_point=point_service.create(point_domain);
			if(result_point!=null) {
				point_flag=1;
			}
		}
		String result_flag=""+member_flag+point_flag;
		if(!result_flag.equals("11")) {
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
			return Integer.parseInt(result_flag);
		}
		
		return Integer.parseInt(result_flag);
	}
	
	@GetMapping("/id_check")
	public int id_check(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(id);
		if(result_optional.isPresent()) {
			return 1011;
		}
		return 1010;
	}
	
	@GetMapping("/login")
	public int login(@RequestParam("id") String id, @RequestParam("password") String password) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.id_check(id);
		if(result_optional.isEmpty()) {
			return 1010;
		}
		MemberDomain result_domain=result_optional.get();
		boolean result_flag=password_encoder.matches(password, result_domain.getPassword());
		if(result_flag) {
			return 1020;
		}
		return 1021;
	}
	
	@PutMapping("/update")
	public int update(@RequestBody MemberDomain member_domain) {
		if(
				member_domain.getId()==null||
				member_domain.getId().equals("")
				) {
			return 1900;
		}

		Optional<MemberDomain> result_optional=member_service.id_check(member_domain.getId());
		if(result_optional.isEmpty()) {
			return 1010;
		}
		MemberDomain member=result_optional.get();
		if(member_domain.getPassword()!=null||!member_domain.getPassword().equals("")) {
			member.setPassword(password_encoder.encode(member_domain.getPassword()));
		}
		if(member_domain.getEmail()!=null||!member_domain.getEmail().equals("")) {
			member.setEmail(member_domain.getEmail());
		}
		if(member_domain.getName()!=null||!member_domain.getName().equals("")) {
			member.setName(member_domain.getName());
		}
		if(member_domain.getBirthday()!=null||!member_domain.getBirthday().equals("")) {
			member.setBirthday(member_domain.getBirthday());
		}
		if(member_domain.getNickname()!=null||!member_domain.getNickname().equals("")) {
			Optional<MemberDomain> temp_optional=member_service.nickname_check(member_domain.getNickname());
			if(temp_optional.isPresent()) {
				return 1041;
			}
			member.setNickname(member_domain.getNickname());
		}
		MemberDomain result_member=member_service.update(member_domain);
		if(result_member!=null) {
			return 1030;
		}
		return 1031;
	}
	
	@Transactional
	@DeleteMapping("/delete")
	public int delete(@RequestParam("id") String id) {
		if (id == null || id.equals("")) {
	        return 1900;
	    }
		int point_flag=0;
	    int point_history_flag=0;
	    int user_reward_item_flag=0;
	    int blocked_device_flag=0;
	    int bluetooth_connected_device=0;
	    int member_flag=0;
	    String result_flag="";
		
	 // 엽전 내역 테이블 삭제, 엽전 테이블 삭제
	    Optional<PointDomain> result_point_optional=point_service.get_info_id_object(id);
	    if(result_point_optional.isPresent()) {
	    	PointDomain point_domain=result_point_optional.get();
	    	List<PointHistoryDomain> result_point_history_list=point_history_service.delete_history_point_no_list(point_domain.getPoint_no());
	    	if(result_point_history_list.isEmpty()) {
	    		point_history_flag=1;
	    	}
	    	Optional<PointDomain> result_point=point_service.delete(point_domain.getPoint_no());
	    	if(result_point.isEmpty()) {
	    		point_flag=1;
	    	}
	    	
	    }
	    
	    // 사용자 보상물 테이블 삭제
	    List<UserRewardItemDomain> result_user_reward_item_list=user_reward_item_service.delete_user_reward_item_id_list(id);
	    if(result_user_reward_item_list.isEmpty()) {
	    	user_reward_item_flag=1;
	    }
	    
	    // 차단 디바이스 삭제
	    List<BlockedDeviceDomain> result_blocked_device_list=blocked_device_service.delete_blocked_device_id_list(id);
	    if(result_blocked_device_list.isEmpty()) {
	    	blocked_device_flag=1;
	    }
	    
	    // 블루투스 연결 디바이스 삭제
	    List<BluetoothConnectedDeviceDomain> result_bluetooth_connected_device_list=bluetooth_connected_device_service.delete_connected_device_id_list(id);
	    if(result_bluetooth_connected_device_list.isEmpty()) {
	    	bluetooth_connected_device=1;
	    }
	    
	    // 이웃 테이블 삭제
	    Optional<MemberDomain> result_member = member_service.delete(id);
	    if(result_member.isEmpty()) {
	    	member_flag=1;
	    }	    
	    
	    result_flag=""+point_flag+point_history_flag+user_reward_item_flag+blocked_device_flag+bluetooth_connected_device+member_flag;
	    
	    if(!result_flag.equals("111111")) {
	    	TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
	    	return Integer.parseInt(result_flag);
	    }
	    return Integer.parseInt(result_flag);	    
	}
	
	@GetMapping("/get_member_object")
	public MemberDomain get_member_object(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return null;
		}
		Optional<MemberDomain> result_optional=member_service.get_member_object(id);
		if(result_optional.isPresent()) {
			return result_optional.get();
		}
		return null;
	}
	
	@GetMapping("/nickname_check")
	public int nickname_check(@RequestParam("nickname") String nickname) {
		if(nickname==null||nickname.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.nickname_check(nickname);
		if(result_optional.isEmpty()) {
			return 1040;
		}
		return 1041;
	}
	
	@GetMapping("/email_check")
	public int email_check(@RequestParam("email") String email) {
		if(email==null||email.equals("")) {
			return 1900;
		}
		Optional<MemberDomain> result_optional=member_service.email_check(email);
		if(result_optional.isEmpty()) {
			return 1060;
		}
		return 1061;
	}
	
	@GetMapping("/get_member_list")
	public List<MemberDomain> get_member_list(){
		return member_service.get_member_list();
	}
	
	@GetMapping("/get_member_email_object")
	public List<MemberDomain> get_member_email_object(@RequestParam("email") String email){
		return member_service.get_member_email_object(email);
	}
}
