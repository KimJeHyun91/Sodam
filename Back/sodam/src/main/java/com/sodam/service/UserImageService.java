package com.sodam.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sodam.domain.UserImageDomain;
import com.sodam.repository.UserImageRepository;

@Service
public class UserImageService {
	@Autowired
	UserImageRepository user_image_repository;
	
	@Transactional
	   public UserImageDomain add_image(UserImageDomain user_image_domain) {
	      String id=user_image_domain.getId();
	      byte[] bytea=user_image_domain.getImage();
	      return user_image_repository.add_image(id, bytea, user_image_domain.getCreated_date(), user_image_domain.getLast_modified_date());
	   }
	@Transactional
	public Optional<UserImageDomain> get_image(String id) {
		return user_image_repository.findById(id);
	}
	@Transactional
	public UserImageDomain update_image(UserImageDomain user_image_domain) {
		return user_image_repository.save(user_image_domain);
	}
	@Transactional
	public Optional<UserImageDomain> delete_image(String id) {
		user_image_repository.deleteById(id);
		return user_image_repository.findById(id);
	}

}
