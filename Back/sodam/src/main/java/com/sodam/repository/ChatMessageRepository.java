package com.sodam.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.sodam.entity.ChatMessage;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByRoomIdOrderBySentAtAsc(Long roomId);
}
