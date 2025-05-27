package com.sodam.domain;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import com.sodam.id.BluetoothConnectedDeviceId;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="bluetooth_connected_device")
@EntityListeners(AuditingEntityListener.class)
public class BluetoothConnectedDeviceDomain {
	@EmbeddedId
	private BluetoothConnectedDeviceId bluetooth_connected_device_id;
	@NotNull
	@Column(nullable=false)
	private String UUID;
	@CreatedDate
	private LocalDateTime created_date;
}
