package com.sodam.service;

import java.util.List;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.BlockedDeviceDomain;
import com.sodam.id.BluetoothConnectedDeviceId;
import com.sodam.repository.BlockedDeviceRepository;

@Service
public class BlockedDeviceService {
	@Autowired
	BlockedDeviceRepository blocked_device_repository;

	@Transactional
	public BlockedDeviceDomain add_blocked_device(BlockedDeviceDomain blocked_device_domain) {
		return blocked_device_repository.save(blocked_device_domain);
	}

	@Transactional(readOnly = true)
	public List<BlockedDeviceDomain> get_blocked_device_list() {
		return blocked_device_repository.findAll();
	}

	@Transactional(readOnly = true)
	public List<BlockedDeviceDomain> get_blocked_device_id_list(String id) {
		return blocked_device_repository.get_blocked_device_id_list(id);
	}

	@Transactional(readOnly = true)
	public Optional<BlockedDeviceDomain> get_blocked_device_object(BluetoothConnectedDeviceId bluetooth_connected_device_id) {
		return blocked_device_repository.findById(bluetooth_connected_device_id);
	}
	
	@Transactional
	public List<BlockedDeviceDomain> delete_blocked_device_list() {
		blocked_device_repository.deleteAll();
		return blocked_device_repository.findAll();
	}

	@Transactional
	public List<BlockedDeviceDomain> delete_blocked_device_id_list(String id) {
		blocked_device_repository.delete_blocked_device_id_list(id);
		return blocked_device_repository.get_blocked_device_id_list(id);
	}
	
	@Transactional
	public Optional<BlockedDeviceDomain> delete_blocked_device_object(BluetoothConnectedDeviceId bluetooth_connected_device_id) {
		blocked_device_repository.deleteById(bluetooth_connected_device_id);
		return blocked_device_repository.findById(bluetooth_connected_device_id);
	}
}
