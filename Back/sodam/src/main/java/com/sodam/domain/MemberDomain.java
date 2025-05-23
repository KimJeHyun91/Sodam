package com.sodam.domain;

import java.time.LocalDateTime;

import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.DynamicInsert;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="member")
@EntityListeners(AuditingEntityListener.class)
public class MemberDomain {
	@Id
	private String id;
	@Column(nullable=false)
	private String password;
	@Column(nullable=false)
	private String email;
	@Column(nullable=false)
	private String name;
	@Column(nullable=false)
	private String birthday;
	@Column(nullable=false)
	private String nickname;
	@CreatedDate
	private LocalDateTime created_date;
	@LastModifiedDate
	private LocalDateTime last_modified_date;
	
	
	
	
}
