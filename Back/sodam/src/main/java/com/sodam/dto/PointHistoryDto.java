package com.sodam.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PointHistoryDto {
	@NotNull
	private String Id;
	@NotNull
	private Long change;
	@NotNull
	private Character point_plus_minus;
	@NotNull
	private String point_change_reason_code;
}
