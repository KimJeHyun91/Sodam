package com.sodam.service;

import java.util.Optional;
import org.springframework.transaction.annotation.Transactional;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.PointDomain;
import com.sodam.repository.PointRepository;

@Service
public class PointService {
	@Autowired
	PointRepository point_repository;

	@Transactional
	public PointDomain update(PointDomain point_domain) {
		return point_repository.save(point_domain);
	}
//	@Transactional
//	public PointDomain update(PointDomain point_domain) {
//	    // 1. 먼저 ID가 null인지 체크
//	    if (point_domain.getPoint_no() == null) {
//	        throw new IllegalArgumentException("PointDomain의 ID가 null이면 update할 수 없습니다.");
//	    }
//
//	    // 2. 기존 객체 불러오기
//	    Optional<PointDomain> optional = point_repository.findById(point_domain.getPoint_no());
//	    if (optional.isEmpty()) {
//	        throw new IllegalArgumentException("해당 ID의 PointDomain이 존재하지 않음: " + point_domain.getPoint_no());
//	    }
//
//	    // 3. 기존 객체에 필드만 업데이트
//	    PointDomain existing = optional.get();
//	    existing.setCurrent_point(point_domain.getCurrent_point());
//
//	    // 필요한 필드가 더 있다면 여기서 다 세팅해줘
//	    return point_repository.save(existing); // 이건 이제 안전한 update
//	}

	@Transactional
	public PointDomain create(PointDomain point_domain) {
		return point_repository.save(point_domain);
	}

	@Transactional
	public Optional<PointDomain> delete(Long point_no) {
		point_repository.deleteById(point_no);
		return point_repository.findById(point_no);
	}
	
	@Transactional(readOnly = true)
	public Optional<PointDomain> get_info_object(Long point_no) {
		return point_repository.findById(point_no);
	}

	@Transactional(readOnly = true)
	public Optional<PointDomain> get_info_id_object(String id) {
		return point_repository.get_info_id_object(id);
	}
}
