package com.sodam.domain;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="user_image")
@EntityListeners(AuditingEntityListener.class)
public class UserImageDomain {
	@Id
	private String id;
	@Lob
	@Column(columnDefinition="BYTEA")
	private byte[] image;
	@CreatedDate
	private LocalDateTime created_date;
	@LastModifiedDate
	private LocalDateTime last_modified_date;
}
