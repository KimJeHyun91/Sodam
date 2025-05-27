package com.sodam.service;

import java.util.List;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.PointChangeReasonDomain;
import com.sodam.repository.PointChangeReasonRepository;

@Service
public class PointChangeReasonService {
	@Autowired
	PointChangeReasonRepository point_change_reason_repository;

	@Transactional(readOnly = true)
	public List<PointChangeReasonDomain> get_change_reason_list() {
		return point_change_reason_repository.findAll();
	}
	
	@Transactional
	public PointChangeReasonDomain add_change_reason(PointChangeReasonDomain point_change_reason_domain) {
		return point_change_reason_repository.save(point_change_reason_domain);
	}

	@Transactional(readOnly = true)
	public Optional<PointChangeReasonDomain> get_change_reason_object(String point_change_reason_code) {
		return point_change_reason_repository.findById(point_change_reason_code);
	}
	
	@Transactional
	public PointChangeReasonDomain update_change_reason(PointChangeReasonDomain point_change_reason_domain) {
		return point_change_reason_repository.save(point_change_reason_domain);
	}

	@Transactional
	public Optional<PointChangeReasonDomain> delete_change_reason(String point_change_reason_code) {
		point_change_reason_repository.deleteById(point_change_reason_code);
		return point_change_reason_repository.findById(point_change_reason_code);
	}
}
