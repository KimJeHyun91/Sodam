package com.sodam.repository;

import com.sodam.entity.ChatRoomParticipant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatRoomParticipantRepository extends JpaRepository<ChatRoomParticipant, Long> {

    List<ChatRoomParticipant> findByChatRoomId(Long chatRoomId);

    List<ChatRoomParticipant> findByUserId(Long userId);
}
