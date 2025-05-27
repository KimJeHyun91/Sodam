package com.sodam.service;

import java.util.List;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.BluetoothConnectedDeviceDomain;
import com.sodam.id.BluetoothConnectedDeviceId;
import com.sodam.repository.BluetoothConnectedDeviceRepository;


@Service
public class BluetoothConnectedDeviceService {
	@Autowired
	BluetoothConnectedDeviceRepository bluetooth_connected_device_repository;
	
	@Transactional
	public BluetoothConnectedDeviceDomain add_connected_device(BluetoothConnectedDeviceDomain bluetooth_connected_device_domain) {
		return bluetooth_connected_device_repository.save(bluetooth_connected_device_domain);
	}

	@Transactional(readOnly = true)
	public List<BluetoothConnectedDeviceDomain> get_connected_device_list() {
		return bluetooth_connected_device_repository.findAll();
	}

	@Transactional(readOnly = true)
	public List<BluetoothConnectedDeviceDomain> get_connected_device_id_list(String id) {
		return bluetooth_connected_device_repository.get_connected_device_id_list(id);
	}

	@Transactional(readOnly = true)
	public Optional<BluetoothConnectedDeviceDomain> get_connected_device_object(BluetoothConnectedDeviceId bluetooth_connected_device_id) {
		return bluetooth_connected_device_repository.findById(bluetooth_connected_device_id);
	}
	
	@Transactional
	public List<BluetoothConnectedDeviceDomain> delete_connected_device_list() {
		bluetooth_connected_device_repository.deleteAll();
		return bluetooth_connected_device_repository.findAll();
	}

	@Transactional
	public List<BluetoothConnectedDeviceDomain> delete_connected_device_id_list(String id) {
		bluetooth_connected_device_repository.delete_connected_device_id_list(id);
		return bluetooth_connected_device_repository.get_connected_device_id_list(id);
	}
	
	@Transactional
	public Optional<BluetoothConnectedDeviceDomain> delete_connected_device_object(BluetoothConnectedDeviceId bluetooth_connected_device_id) {
		bluetooth_connected_device_repository.deleteById(bluetooth_connected_device_id);
		return bluetooth_connected_device_repository.findById(bluetooth_connected_device_id);
	}



}
