package com.sodam.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequestDto {
	@NotBlank(message="아이디를 입력해주세요.")
	private String id;
	@NotBlank(message="비밀번호를 입력해주세요")
	private String password;
}
