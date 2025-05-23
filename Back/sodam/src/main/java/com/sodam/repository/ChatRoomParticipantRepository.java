package com.sodam.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.sodam.entity.ChatRoomParticipant;

public interface ChatRoomParticipantRepository extends JpaRepository<ChatRoomParticipant, Long> {

    List<ChatRoomParticipant> findByChatRoomId(Long chatRoomId);

    List<ChatRoomParticipant> findByUserId(Long userId);
    
    @Query("SELECT c FROM ChatRoomParticipant c WHERE c.chatRoomId = :roomId AND c.lastPing >= :since")
    List<ChatRoomParticipant> findOnlineUsers(@Param("roomId") Long roomId, @Param("since") LocalDateTime since);

}
