package com.sodam.repository;

import com.sodam.entity.ChatRoomHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ChatRoomHistoryRepository extends JpaRepository<ChatRoomHistory, Long> {
    Optional<ChatRoomHistory> findByChatRoomNoAndUserId(Long chatRoomNo, Long userId);
}
