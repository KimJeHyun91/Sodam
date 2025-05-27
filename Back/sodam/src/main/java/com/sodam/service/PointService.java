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
