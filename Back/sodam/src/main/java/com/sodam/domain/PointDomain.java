package com.sodam.domain;

import java.time.LocalDateTime;

import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="POINT")
@EntityListeners(AuditingEntityListener.class)
public class PointDomain {
	@Id
	@SequenceGenerator(
			name="a"
			, sequenceName="point_sequence"
			, initialValue=1
			, allocationSize=1
	)
	@GeneratedValue(generator="a")
	private Long point_no;
	@NotNull
	@Column(nullable=false)
	@ColumnDefault("0")
	private Long current_point;
	@LastModifiedDate
	private LocalDateTime last_modified_date;
	@NotNull
	@Column(nullable=false)
	private String id;
	
	

}
