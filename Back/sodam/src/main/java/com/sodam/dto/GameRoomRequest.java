package com.sodam.dto;

import java.util.List;

public class GameRoomRequest {
    private String gameType;
    private List<String> nickNames;

    public String getGameType() {
        return gameType;
    }

    public void setGameType(String gameType) {
        this.gameType = gameType;
    }

    public List<String> getNickNames() {
        return nickNames;
    }

    public void setNickNames(List<String> nickNames) {
        this.nickNames = nickNames;
    }
}
