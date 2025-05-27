package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.BluetoothConnectedDeviceDomain;
import com.sodam.id.BluetoothConnectedDeviceId;

@Repository
public interface BluetoothConnectedDeviceRepository extends JpaRepository<BluetoothConnectedDeviceDomain, BluetoothConnectedDeviceId>{
	@Query(value="select * from bluetooth_connected_device where id=:a", nativeQuery=true)
	List<BluetoothConnectedDeviceDomain> get_connected_device_id_list(@Param("a") String id);
	
	@Modifying
	@Query(value="delete from bluetooth_connected_device where id=:a", nativeQuery=true)
	void delete_connected_device_id_list(@Param("a") String id);

}
