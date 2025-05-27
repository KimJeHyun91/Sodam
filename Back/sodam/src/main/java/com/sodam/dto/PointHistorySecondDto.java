package com.sodam.dto;

import lombok.Data;

@Data
public class PointHistorySecondDto {
	public Long point_history_no;
	public Long point_no;
	public Long change;
	public Character point_plus_minus;
	public String point_change_reason_code;
}
