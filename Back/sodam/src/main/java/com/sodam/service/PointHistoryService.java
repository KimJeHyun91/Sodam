package com.sodam.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sodam.domain.PointHistoryDomain;
import com.sodam.id.PointHistoryId;
import com.sodam.repository.PointHistoryRepository;

@Service
public class PointHistoryService {
	@Autowired
	PointHistoryRepository point_history_repository;

	@Transactional
	public PointHistoryDomain update(PointHistoryDomain point_history_domain) {
		return point_history_repository.save(point_history_domain);
	}

	@Transactional(readOnly = true)
	public List<PointHistoryDomain> get_history_list() {
		return point_history_repository.findAll();
	}

	@Transactional(readOnly = true)
	public Optional<PointHistoryDomain> get_history_object(PointHistoryId point_history_id) {
		return point_history_repository.findById(point_history_id);
	}

	@Transactional
	public List<PointHistoryDomain> delete_history_list() {
		point_history_repository.deleteAll();
		return point_history_repository.findAll();
	}

	@Transactional
	public Optional<PointHistoryDomain> delete_history_object(PointHistoryId point_history_id) {
		point_history_repository.deleteById(point_history_id);
		return point_history_repository.findById(point_history_id);
	}

	@Transactional
	public List<PointHistoryDomain> delete_history_point_no_list(Long point_no) {
		point_history_repository.delete_history_point_no_list(point_no);
		return point_history_repository.get_history_point_no_list(point_no);
	}

	@Transactional(readOnly = true)
	public List<PointHistoryDomain> get_history_point_no_list(Long point_no) {
		return point_history_repository.get_history_point_no_list(point_no);
	}

	@Transactional
	public PointHistoryDomain create_history(PointHistoryDomain point_history_domain) throws DataIntegrityViolationException{
		Long last_point_history_no=point_history_repository.findMaxPointHistoryNoByPointNo(point_history_domain.getPoint_history_id().getPoint_no());
		if(last_point_history_no==null) {
			last_point_history_no=0L;
		}
		point_history_domain.getPoint_history_id().setPoint_history_no(last_point_history_no+1);;
		try {
            return point_history_repository.save(point_history_domain);
        } catch (DataIntegrityViolationException e) {
            throw e; 
        }
	}

}
