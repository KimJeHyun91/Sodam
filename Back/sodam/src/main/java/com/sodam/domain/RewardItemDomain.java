package com.sodam.domain;

import java.time.LocalDateTime;

import org.hibernate.annotations.Check;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="REWARD_ITEM")
@EntityListeners(AuditingEntityListener.class)
public class RewardItemDomain {
	@Id
	@SequenceGenerator(
			name="reward_item_sequence_generator"
			, sequenceName="REWARD_ITEM_SEQUENCE"
			, initialValue=1
			, allocationSize=1
	)
	@GeneratedValue(generator="reward_item_sequence_generator")
	private Long reward_item_no;
	@NotNull
	@Column(name="\"reward_item_category\"", nullable=false)
	// 윤곽:F(Frame) 특징물:C(Character) 문양:D(Design) 칭호:A(Appellation) 배경:T(Theme)
	@Check(constraints="\"reward_item_category\" IN ('F', 'C', 'D', 'A', 'T')") 
	private Character reward_item_category;
	@NotNull
	@Column(nullable=false)
	private String reward_item_name;
	@NotNull
	@Column(nullable=false)
	private String reward_item_image_url;
	@NotNull
	@Column(nullable=false)
	private String reward_item_description;
	@NotNull
	@Column(nullable=false)
	private Long reward_item_price;
	@CreatedDate
	private LocalDateTime created_date;
	@LastModifiedDate
	private LocalDateTime last_modified_date;
	
	
	
	

}
