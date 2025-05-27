package com.sodam.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PointHistoryDto {
	public Long point_history_no;
	@NotNull
	public Long point_no;
	@NotNull
	public Long change_amount;
	@NotNull
	public Character point_plus_minus;
	@NotNull
	public String point_change_reason_code;
}