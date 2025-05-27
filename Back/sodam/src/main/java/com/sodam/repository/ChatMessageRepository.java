package com.sodam.repository;

import com.sodam.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findByRoomIdOrderBySentAtAsc(Long roomId);

    boolean existsByUuid(String uuid);

    void deleteAllByRoomId(Long roomId);
}
