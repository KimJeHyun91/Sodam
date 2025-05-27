package com.sodam.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sodam.domain.BlockedDeviceDomain;
import com.sodam.id.BluetoothConnectedDeviceId;

@Repository
public interface BlockedDeviceRepository extends JpaRepository<BlockedDeviceDomain, BluetoothConnectedDeviceId>{
	@Query(value="select * from blocked_device where id=:a", nativeQuery=true)
	List<BlockedDeviceDomain> get_blocked_device_id_list(@Param("a") String id);
	
	@Modifying
	@Query(value="delete from blocked_device where id=:a", nativeQuery=true)
	void delete_blocked_device_id_list(@Param("a") String id);

}
