package com.sodam.id;

import java.io.Serializable;

import jakarta.persistence.Embeddable;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class BluetoothConnectedDeviceId implements Serializable{
	private static final long serialVersionUID=1L;
	
	@NotNull
	private String nick_name;
	@NotNull
	private String id;
}
