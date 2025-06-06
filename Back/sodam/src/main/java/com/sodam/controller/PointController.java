package com.sodam.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.domain.PointChangeReasonDomain;
import com.sodam.domain.PointDomain;
import com.sodam.domain.PointHistoryDomain;
import com.sodam.dto.PointHistoryDto;
import com.sodam.id.PointHistoryId;
import com.sodam.service.PointChangeReasonService;
import com.sodam.service.PointHistoryService;
import com.sodam.service.PointService;

import jakarta.transaction.Transactional;

@RestController
@RequestMapping("/point")
public class PointController {
	@Autowired
	PointService point_service;
	@Autowired
	PointHistoryService point_history_service;
	@Autowired
	PointChangeReasonService point_change_reason_service;
	@Autowired
	PointSocketController pointSocketController; //웹소켓땜 넣
	
	@GetMapping("/get_info_object")
	public PointDomain get_info_object(@RequestParam("point_no") Long point_no) {
		if(point_no==null||point_no.equals("")) {
			return null;
		}

		Optional<PointDomain> result_point=point_service.get_info_object(point_no);
		if(result_point.isEmpty()) {
			return null;
		}
		return result_point.get();
	}
	
	@GetMapping("/get_info_id_object")
	public PointDomain get_info_id_object(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return null;
		}
		
		Optional<PointDomain> result_optional=point_service.get_info_id_object(id);
		if(result_optional.isEmpty()) {
			return null;
		}
		return result_optional.get();
	}
	
	@PutMapping("/update")
	public int update(@RequestBody PointDomain point_domain) {
		// 널값, 빈값 체크
		if(
				point_domain.getId()==null||
				point_domain.getId().equals("")||
				point_domain.getCurrent_point()==null||
				point_domain.getCurrent_point().equals("")
		) {
			return 1900;
		}
		PointDomain result_point=point_service.update(point_domain);
		if(result_point!=null) {
			return 1100;
		}
		return 1101;
	}
	
	@GetMapping("/get_change_reason_list")
	public List<PointChangeReasonDomain> get_change_reason_list(){	
		return point_change_reason_service.get_change_reason_list();
	}
	
	@GetMapping("/get_change_reason_object")
	public PointChangeReasonDomain get_change_reason_object(@RequestParam("point_change_reason_code") String point_change_reason_code) {
		if(point_change_reason_code==null||point_change_reason_code.equals("")) {
			return null;
		}
		Optional<PointChangeReasonDomain> result_point_change_reason=point_change_reason_service.get_change_reason_object(point_change_reason_code);
		if(result_point_change_reason.isPresent()) {
			return result_point_change_reason.get();
		}
		return null;
	}
	
	@PostMapping("/add_change_reason")
	public int add_change_reason(@RequestBody PointChangeReasonDomain point_change_reason_domain) {
		if(
				point_change_reason_domain.getPoint_change_reason_code()==null||
				point_change_reason_domain.getPoint_change_reason_code().equals("")||
				point_change_reason_domain.getPoint_change_reason_name()==null||
				point_change_reason_domain.getPoint_change_reason_name().equals("")||
				point_change_reason_domain.getPoint_change_reason_detail()==null||
				point_change_reason_domain.getPoint_change_reason_detail().equals("")
		) {
			return 1900;
		}
		PointChangeReasonDomain result_point_change_reason=point_change_reason_service.add_change_reason(point_change_reason_domain);
		if(result_point_change_reason!=null) {
			return 1110;
		}
		return 1111;
	}
	
	@PutMapping("/update_change_reason")
	public int update_change_reason(@RequestBody PointChangeReasonDomain point_change_reason_domain) {
		if(
				point_change_reason_domain.getPoint_change_reason_code()==null||
				point_change_reason_domain.getPoint_change_reason_code().equals("")
		) {
			return 1900;
		}
		Optional<PointChangeReasonDomain> result_optional=point_change_reason_service.get_change_reason_object(point_change_reason_domain.getPoint_change_reason_code());
		if(result_optional.isEmpty()) {
			return 1121;
		}
		PointChangeReasonDomain temp_point_change_reason=result_optional.get();
		if(point_change_reason_domain.getPoint_change_reason_name()==null) {
			point_change_reason_domain.setPoint_change_reason_name(temp_point_change_reason.getPoint_change_reason_name());
		}
		if(point_change_reason_domain.getPoint_change_reason_detail()==null) {
			point_change_reason_domain.setPoint_change_reason_detail(temp_point_change_reason.getPoint_change_reason_detail());
		}
		PointChangeReasonDomain result_point_change_reason=point_change_reason_service.update_change_reason(point_change_reason_domain);
		if(result_point_change_reason!=null) {
			return 1120;
		}
		return 1121;
	}
	
	@DeleteMapping("/delete_change_reason")
	public int delete_change_reason(@RequestParam("point_change_reason_code") String point_change_reason_code) {
		if(
				point_change_reason_code==null||
				point_change_reason_code.equals("")
		) {
			return 1900;
		}
		Optional<PointChangeReasonDomain> result_point_change_reason=point_change_reason_service.delete_change_reason(point_change_reason_code);
		if(result_point_change_reason.isPresent()) {
			return 1131;
		}
		return 1130;
	}
	
	@PostMapping("/create")
	public int create(@RequestBody PointDomain point_domain) {
		if(
				point_domain.getId()==null||
				point_domain.getId().equals("")
		) {
			return 1900;
		}
		
		PointDomain result_point=point_service.create(point_domain);
		if(result_point!=null) {
			return 1140;
		}
		return 1141;
	}
	
	@DeleteMapping("/delete")
	public int delete(@RequestParam("id") String id) {
		if(
				id==null||
				id.equals("")
		) {
			return 1900;
		}
		Optional<PointDomain> result_point=point_service.get_info_id_object(id);
		if(result_point.isEmpty()) {
			return 1151;
		}
		Optional<PointDomain> result_optional=point_service.delete(result_point.get().getPoint_no());
		if(result_optional.isPresent()) {
			return 1151;
		}
		return 1150;
	}
	
	@GetMapping("/get_history_list")
	public List<PointHistoryDomain> get_history_list(){
		return point_history_service.get_history_list();
	}
	
	@GetMapping("/get_history_point_no_list")
	public List<PointHistoryDomain> get_history_point_no_list(@RequestParam("id") String id){
		if(
				id==null||
				id.equals("")
		) {
			return null;
		}
		Optional<PointDomain> result_point=point_service.get_info_id_object(id);
		if(result_point.isEmpty()) {
			return null;
		}
		return point_history_service.get_history_point_no_list(result_point.get().getPoint_no());
	}
	
	@GetMapping("/get_history_object")
	public PointHistoryDomain get_history_object(@RequestParam("point_history_no") Long point_history_no, @RequestParam("point_no") Long point_no) {
		if(
				point_history_no==null||
				point_no==null
		) {
			return null;
		}
		
		PointHistoryId point_history_id=new PointHistoryId();
		point_history_id.setPoint_no(point_no);
		point_history_id.setPoint_history_no(point_history_no);
		
		Optional<PointHistoryDomain> result_optional=point_history_service.get_history_object(point_history_id);
		if(result_optional.isPresent()) {
			return result_optional.get();
		}
		return null;
	}
	
	@PostMapping("/create_history")
	public int create_history(@RequestBody PointHistoryDto point_history_dto) {
		if(
				point_history_dto.getPoint_no()==null||
				point_history_dto.getPoint_no().equals("")||
				point_history_dto.getChange_amount()==null||
				point_history_dto.getChange_amount().equals("")||
				point_history_dto.getPoint_plus_minus()==null||
				point_history_dto.getPoint_plus_minus().equals("")||
				point_history_dto.getPoint_change_reason_code()==null||
				point_history_dto.getPoint_change_reason_code().equals("")
		) {
			return 1900;
		}

		if(!(point_history_dto.getPoint_plus_minus().equals('P')||point_history_dto.getPoint_plus_minus().equals('M'))) {
			return 1162;
		}
		

		List<PointChangeReasonDomain> result_list=point_change_reason_service.get_change_reason_list();
		if(result_list.size()>0) {
			boolean temp_flag=false;
			for(PointChangeReasonDomain a : result_list) {
				if(a.getPoint_change_reason_code().equals(point_history_dto.getPoint_change_reason_code())) {
					temp_flag=true;
				}
			}
			if(!temp_flag) {
				return 1163;
			}
		}
		
		int point_flag=0;
		int point_history_flag=0;
		
		System.out.println("sdfsdfsd아아아아ㅏ3" + point_history_dto.getPoint_no());

		// 엽전 수정
		Optional<PointDomain> result_point_optional=point_service.get_info_object(point_history_dto.getPoint_no());
		if(result_point_optional.isPresent()) {
			
			PointDomain point_domain=result_point_optional.get();
			
			point_domain.setPoint_no(point_history_dto.getPoint_no());
			if(point_history_dto.getPoint_plus_minus().equals('P')) {
				point_domain.setCurrent_point(point_domain.getCurrent_point()+point_history_dto.getChange_amount());
			}else if(point_history_dto.getPoint_plus_minus().equals('M')) {
				if(point_domain.getCurrent_point()<point_history_dto.getChange_amount()) {
					return 1102;
				}
				point_domain.setCurrent_point(point_domain.getCurrent_point()-point_history_dto.getChange_amount());
			}

			PointDomain result_point=point_service.update(point_domain);		
			if(result_point!=null) {
				point_flag=1;
			}
		}
		
		// 엽전 내역 생성
		PointHistoryDomain point_history_domain=new PointHistoryDomain();
		
		PointHistoryId point_history_id=new PointHistoryId();
		point_history_id.setPoint_no(point_history_dto.getPoint_no());
		point_history_domain.setPoint_history_id(point_history_id);
		point_history_domain.setChange_amount(point_history_dto.getChange_amount());
		point_history_domain.setPoint_plus_minus(point_history_dto.getPoint_plus_minus());
		point_history_domain.setPoint_change_reason_code(point_history_dto.getPoint_change_reason_code());
			
		try {
            PointHistoryDomain result_point_history = point_history_service.create_history(point_history_domain);
            if (result_point_history != null && result_point_history.getPoint_history_id() != null && result_point_history.getPoint_history_id().getPoint_history_no() != null) {
            	point_history_flag=1;
            } else {
            	point_history_flag=0;
            }
        } catch (DataIntegrityViolationException e) {
        	TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return 1157;
        } catch (IllegalArgumentException e) {
        	TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return 1158;
        }	
			
		String result_flag=""+point_flag+point_history_flag;
		
		if(!result_flag.equals("11")) {
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
			return Integer.parseInt(result_flag);
		}
		
		Optional<PointDomain> updatedPointOpt = point_service.get_info_object(point_history_dto.getPoint_no());
		if (updatedPointOpt.isPresent()) {
		    PointDomain updatedPoint = updatedPointOpt.get();
		    pointSocketController.sendPointUpdate(
		    	updatedPoint.getId(),
		    	updatedPoint.getCurrent_point().intValue()
		    );
		}
		
		return Integer.parseInt(result_flag); 

	}
	
	@PutMapping("/update_history")
	public int update_history(@RequestBody PointHistoryDto point_history_dto) {
		if(
				point_history_dto.getPoint_history_no()==null||
				point_history_dto.getPoint_no()==null
		) {
			return 1900;
		}
		
		// point_plus_minus 값 체크
		if(!(point_history_dto.getPoint_plus_minus().equals('P')||point_history_dto.getPoint_plus_minus().equals('M'))) {
			return 1162;
		}
		
		PointHistoryId point_history_id=new PointHistoryId();
		point_history_id.setPoint_no(point_history_dto.getPoint_no());
		point_history_id.setPoint_history_no(point_history_dto.getPoint_history_no());
		Optional<PointHistoryDomain> result_optional=point_history_service.get_history_object(point_history_id);
		if(result_optional.isEmpty()) {
			return 1161;
		}
		PointHistoryDomain point_history_domain=result_optional.get();
		
		
		if(point_history_dto.getChange_amount()!=null) {
			point_history_domain.setChange_amount(point_history_dto.getChange_amount());
		}
		if(point_history_dto.getPoint_plus_minus()!=null) {
			point_history_domain.setPoint_plus_minus(point_history_dto.getPoint_plus_minus());
		}
		if(point_history_dto.getPoint_change_reason_code()!=null) {
			// point_change_reason_code 값 체크
			List<PointChangeReasonDomain> result_list=point_change_reason_service.get_change_reason_list();
			if(result_list.isEmpty()) {
				return 1161;
			}
			boolean temp_flag=false;
			for(PointChangeReasonDomain a : result_list) {
				if(a.getPoint_change_reason_code().equals(point_history_dto.getPoint_change_reason_code())) {
					temp_flag=true;
				}
			}
			if(!temp_flag) {
				return 1163;
			}
			point_history_domain.setPoint_change_reason_code(point_history_dto.getPoint_change_reason_code());
		}
		
		PointHistoryDomain result_point_history=point_history_service.update(point_history_domain);
		if(result_point_history==null) {
			return 1161;
		}
		return 1160;
	}
	
	@DeleteMapping("/delete_history_list")
	public int delete_history_list() {
		List<PointHistoryDomain> result_list=point_history_service.delete_history_list();
		if(result_list.isEmpty()) {
			return 1170;
		}
		return 1171;
	}
	
	@DeleteMapping("/delete_history_point_no_list")
	public int delete_history_list(@RequestParam("id") String id) {
		if(
				id==null||
				id.equals("")
		) {
			return 1900;
		}
		Optional<PointDomain> point_domain=point_service.get_info_id_object(id);
		List<PointHistoryDomain> result_list=point_history_service.delete_history_point_no_list(point_domain.get().getPoint_no());
		if(result_list.isEmpty()) {
			return 1190;
		}
		return 1191;
	}
	
	@DeleteMapping("/delete_history_object")
	public int delete_history_object(@RequestParam("point_history_no") Long point_history_no, @RequestParam("point_no") Long point_no) {
		if(
				point_history_no==null||
				point_no==null
		) {
			return 1900;
		}
		PointHistoryId point_history_id=new PointHistoryId();
		point_history_id.setPoint_no(point_no);
		point_history_id.setPoint_history_no(point_history_no);
		
		Optional<PointHistoryDomain> result_optional=point_history_service.delete_history_object(point_history_id);
		if(result_optional.isPresent()) {
			return 1181;
		}
		return 1180;
	}
	
}
