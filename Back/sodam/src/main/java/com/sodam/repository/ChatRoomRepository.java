package com.sodam.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.sodam.entity.ChatRoom;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    List<ChatRoom> findByUserAIdOrUserBId(Long userAId, Long userBId);
}
