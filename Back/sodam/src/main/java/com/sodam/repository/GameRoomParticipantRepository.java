package com.sodam.repository;

import com.sodam.entity.GameRoomParticipant;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameRoomParticipantRepository extends JpaRepository<GameRoomParticipant, Long> {
}
