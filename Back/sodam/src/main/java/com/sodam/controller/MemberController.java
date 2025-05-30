package com.sodam.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.sodam.domain.BlockedDeviceDomain;
import com.sodam.domain.BluetoothConnectedDeviceDomain;
import com.sodam.domain.MemberDomain;
import com.sodam.domain.PointDomain;
import com.sodam.domain.PointHistoryDomain;
import com.sodam.domain.UserImageDomain;
import com.sodam.domain.UserRewardItemDomain;
import com.sodam.dto.LoginRequestDto;
import com.sodam.dto.LoginResponseDto;
import com.sodam.service.BlockedDeviceService;
import com.sodam.service.BluetoothConnectedDeviceService;
import com.sodam.service.EmailService;
import com.sodam.service.MemberService;
import com.sodam.service.PointHistoryService;
import com.sodam.service.PointService;
import com.sodam.service.UserDetailsServiceImplement;
import com.sodam.service.UserImageService;
import com.sodam.service.UserRewardItemService;
import com.sodam.util.JwtUtil;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;

@RestController
@RequestMapping("/member")
public class MemberController {
	@Autowired private MemberService member_service;
    @Autowired private PointService point_service;
    @Autowired private PointHistoryService point_history_service;
    @Autowired private BluetoothConnectedDeviceService bluetooth_connected_device_service;
    @Autowired private BlockedDeviceService blocked_device_service;
    @Autowired private UserRewardItemService user_reward_item_service;
    @Autowired private EmailService emailService;
    @Autowired private UserDetailsServiceImplement user_details_service_implement;
    @Autowired private AuthenticationManager authentication_manager;
    @Autowired private PasswordEncoder password_encoder;
    @Autowired private JwtUtil jwt_util; 
    @Autowired private UserImageService user_image_service;
	
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

		if(member_domain.getAuthorization()==null) {
			member_domain.setAuthorization('U');
		}


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
	
	@PostMapping("/login")
	public ResponseEntity<?> login(@RequestBody LoginRequestDto login_request_dto) {
		if(
				login_request_dto.getId()==null||
				login_request_dto.getId().equals("")||
				login_request_dto.getPassword()==null||
				login_request_dto.getPassword().equals("")
				) {
			
			return ResponseEntity.status(HttpServletResponse.SC_UNAUTHORIZED).body(new LoginResponseDto(null, 1900, null, null));
		}
		try {
			authentication_manager.authenticate(
					new UsernamePasswordAuthenticationToken(login_request_dto.getId(), login_request_dto.getPassword())
			);
		}catch(BadCredentialsException e) {
			return ResponseEntity.status(HttpServletResponse.SC_UNAUTHORIZED).body(new LoginResponseDto(null, 1021, null, null));
		}catch(Exception e) {
			return ResponseEntity.status(HttpServletResponse.SC_UNAUTHORIZED).body(new LoginResponseDto(null, 1021, null, null));
		}
		
		final UserDetails user_details=user_details_service_implement.loadUserByUsername(login_request_dto.getId());
		
		Optional<MemberDomain> member_optional=member_service.get_member_object(login_request_dto.getId());
		String nickname=member_optional.map(MemberDomain::getNickname).orElse(null);
		
		final String jwt=jwt_util.generateToken(user_details.getUsername());
		return ResponseEntity.ok(new LoginResponseDto(jwt, 1020, user_details.getUsername(), nickname));
	}
	
	@PutMapping("/update")
	public int update(@RequestBody MemberDomain member_domain) {

	    if (member_domain.getId() == null || member_domain.getId().isEmpty()) {
	        return 1900; // ID 누락
	    }

	    Optional<MemberDomain> result_optional = member_service.id_check(member_domain.getId());
	    if (result_optional.isEmpty()) {
	        return 1010; // 해당 ID 사용자 없음
	    }

	    MemberDomain member = result_optional.get();

	    if (member_domain.getPassword() != null && !member_domain.getPassword().isEmpty()) {
	        member.setPassword(password_encoder.encode(member_domain.getPassword()));
	    }
	    if (member_domain.getEmail() != null && !member_domain.getEmail().isEmpty()) {
	        member.setEmail(member_domain.getEmail());
	    }
	    if (member_domain.getName() != null && !member_domain.getName().isEmpty()) {
	        member.setName(member_domain.getName());
	    }
	    if (member_domain.getBirthday() != null && !member_domain.getBirthday().isEmpty()) {
	        member.setBirthday(member_domain.getBirthday());
	    }
	    if (member_domain.getNickname() != null && !member_domain.getNickname().isEmpty()) {
	        // 닉네임 중복 확인 (자기 자신은 허용)
	        Optional<MemberDomain> temp_optional = member_service.nickname_check(member_domain.getNickname());
	        if (temp_optional.isPresent() && !temp_optional.get().getId().equals(member.getId())) {
	            return 1041; // 닉네임 중복
	        }
	        member.setNickname(member_domain.getNickname());
	    }

	    MemberDomain result_member = member_service.update(member);
	    if (result_member != null) {
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
	


	@PostMapping("/reset-password")
	public int resetPassword(@RequestBody Map<String, String> request) {
	    String email = request.get("email");
	    String code = request.get("code");
	    String newPassword = request.get("newPassword");

	    if (email == null || code == null || newPassword == null) {
	        return 1900; 
	    }
	    boolean verified = emailService.verifyCode(email, code);
	    if (!verified) {
	        return 1051; 
	    }
	    Optional<MemberDomain> optional = member_service.email_check(email);
	    if (optional.isEmpty()) {
	        return 1010; 
	    }
	    MemberDomain member = optional.get();
	    if (password_encoder.matches(newPassword, member.getPassword())) {
	        return 1052;
	    }
	    member.setPassword(password_encoder.encode(newPassword));
	    MemberDomain updated = member_service.update(member);
	    return (updated != null) ? 1050 : 1051;
	}



	@PostMapping("/add_image/{id}")
	public int add_image(@PathVariable("id") String id, @RequestParam("image") MultipartFile image) throws IOException {
		if(		
				id==null||
				id.equals("")||
				image==null||
				image.equals("")
		) {
			return 1900;
		}
		System.out.println("dddddddddddddddddddd"+image.getBytes());
		UserImageDomain user_image_domain=new UserImageDomain();
		user_image_domain.setId(id);
		try {
			user_image_domain.setImage(image.getBytes());
			UserImageDomain result_user_image=user_image_service.add_image(user_image_domain);
			if(result_user_image!=null) {
				return 1070;
			}
		} catch (IOException e) {
			e.printStackTrace();
			return 1071;
		}
		
		return 1071;
	}
	
	@GetMapping("/get_image")
	public byte[] get_image(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return null;
		}
		
		Optional<UserImageDomain> user_image_optional=user_image_service.get_image(id);
		if(user_image_optional.isPresent()) {
			UserImageDomain user_image_domain=user_image_optional.get();
			byte[] image=user_image_domain.getImage();
			if(image==null||image.length==0) {
				return null;
			}
			return image;
			
		}
		return null;
	}
	
	@PutMapping("/update_image/{id}")
	public int update_image(@PathVariable String id, @RequestParam("image") MultipartFile image) {
		if(id==null||id.equals("")||image==null||image.equals("")) {
			return 1900;
		}
		Optional<UserImageDomain> user_image_optional=user_image_service.get_image(id);
		if(user_image_optional.isEmpty()) {
			return 1081;
		}
		UserImageDomain user_image_domain=user_image_optional.get();
		try {
			user_image_domain.setImage(image.getBytes());
		} catch (IOException e) {
			e.printStackTrace();
			return 1081;
		}
		UserImageDomain result_user_image=user_image_service.update_image(user_image_domain);
		if(result_user_image!=null) {
			return 1080;
		}
		return 1081;
	}
	
	@DeleteMapping("/delete_image")
	public int delete_image(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		Optional<UserImageDomain> user_image_optional=user_image_service.get_image(id);
		if(user_image_optional.isEmpty()) {
			return 1091;
		}
		Optional<UserImageDomain> result_user_image=user_image_service.delete_image(id);
		if(result_user_image.isEmpty()) {
			return 1090;
		}
		return 1091;
	}
	
	@GetMapping("/find-id")
	   public ResponseEntity<?> findIdByEmail(@RequestParam("email") String email) {
	       if (email == null || email.isBlank()) {
	           return ResponseEntity.badRequest().body(Map.of("status", "fail", "message", "이메일을 입력해주세요."));
	       }

	       Optional<MemberDomain> memberOpt = member_service.email_check(email);
	       if (memberOpt.isEmpty()) {
	           return ResponseEntity.status(404).body(Map.of("status", "fail", "message", "사용자를 찾을 수 없습니다."));
	       }

	       return ResponseEntity.ok(Map.of(
	           "status", "success",
	           "id", memberOpt.get().getId()
	       ));
	   }

}
