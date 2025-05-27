package com.sodam.dto;

import com.sodam.enums.GameType;
import java.time.LocalDateTime;
import java.util.List;

public class GameRoomResponse {
    private Long id;
    private GameType gameType;
    private LocalDateTime createdDate;
    private List<String> participants;

    public GameRoomResponse(Long id, GameType gameType, LocalDateTime createdDate, List<String> participants) {
        this.id = id;
        this.gameType = gameType;
        this.createdDate = createdDate;
        this.participants = participants;
    }

    public Long getId() { return id; }
    public GameType getGameType() { return gameType; }
    public LocalDateTime getCreatedDate() { return createdDate; }
    public List<String> getParticipants() { return participants; }
}
