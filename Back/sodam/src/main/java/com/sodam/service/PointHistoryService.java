package com.sodam.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.PointHistoryDomain;
import com.sodam.id.PointHistoryId;
import com.sodam.repository.PointHistoryRepository;

@Service
public class PointHistoryService {
	@Autowired
	PointHistoryRepository point_histroy_repository;

	public PointHistoryDomain update(PointHistoryDomain point_history_domain) {
		return point_histroy_repository.save(point_history_domain);
	}

	public List<PointHistoryDomain> get_history_list(Long point_no) {
		return point_histroy_repository.get_history_list(point_no);
	}

	public Optional<PointHistoryDomain> get_history_object(PointHistoryId point_history_id) {
		return point_histroy_repository.findById(point_history_id);
	}

	public List<PointHistoryDomain> delete_history_all(Long point_no) {
		point_histroy_repository.delete_history_all(point_no);
		return point_histroy_repository.get_history_list(point_no);
	}
}
