package com.sodam.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sodam.domain.BlockedDeviceDomain;
import com.sodam.domain.BluetoothConnectedDeviceDomain;
import com.sodam.dto.BlockedDeviceDto;
import com.sodam.dto.BluetoothConnectedDeviceDto;
import com.sodam.id.BluetoothConnectedDeviceId;
import com.sodam.service.BlockedDeviceService;
import com.sodam.service.BluetoothConnectedDeviceService;

@RestController
@RequestMapping("/bluetooth")
public class BluetoothController {
	@Autowired
	BluetoothConnectedDeviceService bluetooth_connected_device_service;
	@Autowired
	BlockedDeviceService blocked_device_service;
	
	@PostMapping("/add_connected_device")
	public int add_connected_device(@RequestBody BluetoothConnectedDeviceDto bluetooth_connected_device_dto) {
		if(
				bluetooth_connected_device_dto.getNick_name()==null||
				bluetooth_connected_device_dto.getNick_name().equals("")||
				bluetooth_connected_device_dto.getId()==null||
				bluetooth_connected_device_dto.getId().equals("")||
				bluetooth_connected_device_dto.getUUID()==null||
				bluetooth_connected_device_dto.getUUID().equals("")
		) {
			return 1900;
		}
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(bluetooth_connected_device_dto.getId());
		bluetooth_connected_device_id.setNick_name(bluetooth_connected_device_dto.getNick_name());
		
		BluetoothConnectedDeviceDomain bluetooth_connected_device_domain=new BluetoothConnectedDeviceDomain();
		bluetooth_connected_device_domain.setBluetooth_connected_device_id(bluetooth_connected_device_id);
		bluetooth_connected_device_domain.setUUID(bluetooth_connected_device_dto.getUUID());
		
		BluetoothConnectedDeviceDomain result_bluetooth_connected_device=bluetooth_connected_device_service.add_connected_device(bluetooth_connected_device_domain);
		if(result_bluetooth_connected_device!=null) {
			return 1500;
		}
		return 1501;
	}
	
	@GetMapping("/get_connected_device_list")
	public List<BluetoothConnectedDeviceDomain> get_connected_device_list(){
		return bluetooth_connected_device_service.get_connected_device_list();
	}
	
	@GetMapping("/get_connected_device_id_list")
	public List<BluetoothConnectedDeviceDomain> get_connected_device_id_list(@RequestParam("id") String id){
		if(id==null||id.equals("")) {
			return null;
		}
		return bluetooth_connected_device_service.get_connected_device_id_list(id);
	}
	
	@GetMapping("/get_connected_device_object")
	public BluetoothConnectedDeviceDomain get_connected_device_object(@RequestParam("id") String id, @RequestParam("nick_name") String nick_name) {
		if(id==null||id.equals("")||nick_name==null||nick_name.equals("")) {
			return null;
		}
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(id);
		bluetooth_connected_device_id.setNick_name(nick_name);
		Optional<BluetoothConnectedDeviceDomain> result_optional=bluetooth_connected_device_service.get_connected_device_object(bluetooth_connected_device_id);
		if(result_optional.isPresent()) {
			return result_optional.get();
		}
		return null;
	}
	
	@DeleteMapping("/delete_connected_device_list")
	public int delete_connected_device_list() {
		List<BluetoothConnectedDeviceDomain> result_list=bluetooth_connected_device_service.delete_connected_device_list();
		if(result_list.isEmpty()) {
			return 1510;
		}
		return 1511;
	}
	
	@DeleteMapping("/delete_connected_device_id_list")
	public int delete_connected_device_id_list(@RequestParam("id") String id) {
		if(id==null||id.equals("")) {
			return 1900;
		}
		List<BluetoothConnectedDeviceDomain> result_list=bluetooth_connected_device_service.delete_connected_device_id_list(id);
		if(result_list.isEmpty()){
			return 1520;
		}
		return 1521;
	}
	
	@DeleteMapping("/delete_connected_device_object")
	public int delete_connected_device_object(@RequestParam("id") String id, @RequestParam("nick_name") String nick_name) {
		if(id==null||id.equals("")||nick_name==null||nick_name.equals("")) {
			return 1900;
		}
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(id);
		bluetooth_connected_device_id.setNick_name(nick_name);
		Optional<BluetoothConnectedDeviceDomain> result_optional=bluetooth_connected_device_service.delete_connected_device_object(bluetooth_connected_device_id);
		if(result_optional.isEmpty()) {
			return 1530;
		}
		return 1531;
	}
	
	@PostMapping("/add_blocked_device")
	public int add_blocked_device(@RequestBody BlockedDeviceDto blocked_device_dto) {
		if(
				blocked_device_dto.getId()==null||
				blocked_device_dto.getId().equals("")||
				blocked_device_dto.getNick_name()==null||
				blocked_device_dto.getNick_name().equals("")
		) {
			return 1900;
		}
		
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(blocked_device_dto.getId());
		bluetooth_connected_device_id.setNick_name(blocked_device_dto.getNick_name());
		
		BlockedDeviceDomain blocked_device_domain=new BlockedDeviceDomain();
		blocked_device_domain.setBluetooth_connected_device_id(bluetooth_connected_device_id);
		
		BlockedDeviceDomain result_blocked_device=blocked_device_service.add_blocked_device(blocked_device_domain);
		if(result_blocked_device!=null) {
			return 1540;
		}
		return 1541;
	}
	
	@GetMapping("/get_blocked_device_list")
	public List<BlockedDeviceDomain> get_blocked_device_list(){
		return blocked_device_service.get_blocked_device_list();
	}
	
	@GetMapping("/get_blocked_device_id_list")
	public List<BlockedDeviceDomain> get_blocked_device_id_list(@RequestParam("id") String id){
		if(id==null||id.equals("")) {
			return null;
		}
		return blocked_device_service.get_blocked_device_id_list(id);
	}
	
	@GetMapping("/get_blocked_device_object")
	public BlockedDeviceDomain get_blocked_device_object(@RequestParam("id") String id, @RequestParam("nick_name") String nick_name) {
		if(id==null||id.equals("")||nick_name==null||nick_name.equals("")) {
			return null;
		}
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(id);
		bluetooth_connected_device_id.setNick_name(nick_name);
		
		Optional<BlockedDeviceDomain> result_optional=blocked_device_service.get_blocked_device_object(bluetooth_connected_device_id);
		if(result_optional.isPresent()) {
			return result_optional.get();
		}
		return null;
	}
	
	@DeleteMapping("/delete_blocked_device_list")
	public int delete_blocked_device_list() {
		List<BlockedDeviceDomain> result_list=blocked_device_service.delete_blocked_device_list();
		if(result_list.isEmpty()) {
			return 1550;
		}
		return 1551;
	}
	
	@DeleteMapping("/delete_blocked_device_id_list")
	public int delete_blocked_device_id_list(@RequestParam("id") String id) {
		List<BlockedDeviceDomain> result_list=blocked_device_service.delete_blocked_device_id_list(id);
		if(result_list.isEmpty()) {
			return 1560;
		}
		return 1561;
	}
	
	@DeleteMapping("/delete_blocked_device_object")
	public int delete_blocked_device_object(@RequestParam("id") String id, @RequestParam("nick_name") String nick_name) {
		if(id==null||id.equals("")||nick_name==null||nick_name.equals("")) {
			return 1900;
		}
		BluetoothConnectedDeviceId bluetooth_connected_device_id=new BluetoothConnectedDeviceId();
		bluetooth_connected_device_id.setId(id);
		bluetooth_connected_device_id.setNick_name(nick_name);
		
		Optional<BlockedDeviceDomain> result_optional=blocked_device_service.delete_blocked_device_object(bluetooth_connected_device_id);
		if(result_optional.isEmpty()) {
			return 1570;
		}
		return 1571;
	}
}
