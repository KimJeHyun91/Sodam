package com.sodam.repository;

import com.sodam.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    // 기존 1:1 채팅용
    List<ChatRoom> findByUserAIdOrUserBId(Long userAId, Long userBId);

   
}
