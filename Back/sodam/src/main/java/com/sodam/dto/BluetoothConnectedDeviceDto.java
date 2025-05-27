package com.sodam.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BluetoothConnectedDeviceDto {
	@NotNull
	private String nick_name;
	@NotNull
	private String id;
	@NotNull
	private String UUID;
}
