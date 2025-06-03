package com.sodam.domain;

import java.time.LocalDateTime;

import org.hibernate.annotations.Check;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="MEMBER")
@EntityListeners(AuditingEntityListener.class)
public class MemberDomain {
	@Id
	private String id;
	@NotNull
	@Column(nullable=false)
	private String password;
	@NotNull
	@Column(nullable=false)
	private String email;
	@NotNull
	@Column(nullable=false)
	private String name;
	@NotNull
	@Column(nullable=false)
	private String birthday;
	@NotNull
	@Column(nullable=false)
	private String nickname;
	@NotNull
	@Column(name = "\"authorization\"", nullable=false)
	@ColumnDefault("'U'")
    @Check(constraints = "\"authorization\" IN ('U', 'A')")
	private Character authorization;
	@CreatedDate
	private LocalDateTime created_date;
	@LastModifiedDate
	private LocalDateTime last_modified_date;
	
	
	
	
}
