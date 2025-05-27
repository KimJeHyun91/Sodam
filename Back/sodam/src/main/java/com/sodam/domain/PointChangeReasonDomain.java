package com.sodam.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="POINT_CHANGE_REASON")
public class PointChangeReasonDomain {
	@Id
	private String point_change_reason_code;
	@NotNull
	@Column(nullable=false)
	private String point_change_reason_name;
	@NotNull
	@Column(nullable=false)
	private String point_change_reason_detail;
}
