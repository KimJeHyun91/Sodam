package com.sodam.service;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.sodam.domain.MemberDomain;
import com.sodam.repository.MemberRepository;


@Service
public class MemberService {
	@Autowired
	MemberRepository member_repository;
	
	@Transactional(readOnly = true)
	public Optional<MemberDomain> id_check(String id) {
		return member_repository.findById(id);
	}

	@Transactional
	public MemberDomain add(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}
	
	@Transactional
	public MemberDomain update(MemberDomain member_domain) {
		return member_repository.save(member_domain);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> nickname_check(String nickname) {
		return member_repository.nickname_check(nickname);
	}
	
	@Transactional
	public Optional<MemberDomain> delete(String id) {
		member_repository.deleteById(id);
		return member_repository.findById(id);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> get_member_object(String id) {
		return member_repository.findById(id);
	}

	@Transactional(readOnly = true)
	public Optional<MemberDomain> email_check(String email) {
		return member_repository.email_check(email);
	}

	@Transactional(readOnly = true)
	public List<MemberDomain> get_member_list() {
		return member_repository.findAll();
	}
	
	@Transactional(readOnly = true)
	public List<MemberDomain> get_member_email_object(String email) {
		return member_repository.get_member_email_object(email);
	}
	
	@Value("${file.upload-dir}")
	private String upload_dir;
	
	@Transactional
	public String add_image(String id, MultipartFile image) throws IOException {
		Optional<MemberDomain> member_optional=member_repository.findById(id);
		if(member_optional.isEmpty()) {
			throw new IllegalArgumentException("ID가 "+id+"인 사용자를 찾을 수 없습니다.");
		}
		
		MemberDomain member_domain=member_optional.get();
		
		String original_file_name=StringUtils.cleanPath(image.getOriginalFilename());
		String file_exception="";
		int last_dot=original_file_name.lastIndexOf('.');
		if(last_dot>0&&last_dot<original_file_name.length()-1) {
			file_exception=original_file_name.substring(last_dot);
		}
		String unique_file_name=UUID.randomUUID().toString()+file_exception;
		
		Path upload_path=Paths.get(this.upload_dir);
		
		if(!Files.exists(upload_path)) {
			Files.createDirectories(upload_path);
		}
		
		if(member_domain.getImage_url()!=null&&!member_domain.getImage_url().isEmpty()) {
			try {
				Path old_image_path=upload_path.resolve(member_domain.getImage_url());
				Files.deleteIfExists(old_image_path);
			}catch (IOException e){
				System.out.println("이전 프로필 이미지 삭제 실패");
			}
		}
		
		Path file_path=upload_path.resolve(unique_file_name);
		
		try (InputStream input_stream=image.getInputStream()){
			Files.copy(input_stream, file_path, StandardCopyOption.REPLACE_EXISTING);
		}catch (IOException e) {
			throw new IOException("이미지 파일 저장 실패");
		}
		
		member_domain.setImage_url(unique_file_name);
		member_repository.save(member_domain);
			
		return unique_file_name;
	}
	@Transactional(readOnly=true)
	public Resource get_image(String id) throws MalformedURLException{
		Optional<MemberDomain> member_optional=member_repository.findById(id);
		if(member_optional.isEmpty()) {
			return null;
		}
		MemberDomain member_domain=member_optional.get();
		String image_name=member_domain.getImage_url();
		
		if(image_name==null||image_name.equals("")) {
			return null;
		}
		
		try {
			Path image_path=Paths.get(upload_dir).resolve(image_name).normalize();
			Resource resource=new UrlResource(image_path.toUri());
			
			if(resource.exists()&&resource.isReadable()) {
				return resource;
			}else {
				return null;
			}
		}catch (MalformedURLException e) {
			return null;
		}catch (Exception e) {
			return null;
		}
		
	}
	@Transactional
	public int delete_image(String id) {
		Optional<MemberDomain> member_optional=member_repository.findById(id);
		if(member_optional.isEmpty()) {
			return 1091;
		}
		MemberDomain member_domain=member_optional.get();
		if(member_domain.getImage_url()==null||member_domain.getImage_url().equals("")) {
			return 1091;
		}
		Path upload_path=Paths.get(this.upload_dir);
		Path old_image_path=upload_path.resolve(member_domain.getImage_url());
		try {
			Files.deleteIfExists(old_image_path);
			return 1090;
		}catch(IOException e) {
			return 1091;
		}catch(Exception e) {
			return 1091;
		}
		
		
	}

}