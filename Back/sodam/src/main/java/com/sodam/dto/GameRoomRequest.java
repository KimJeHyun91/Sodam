package com.sodam.dto;

import java.util.List;

public class GameRoomRequest {
    private String gameType;
    private List<ParticipantDTO> participants;

    public String getGameType() {
        return gameType;
    }

    public void setGameType(String gameType) {
        this.gameType = gameType;
    }

    public List<ParticipantDTO> getParticipants() {
        return participants;
    }

    public void setParticipants(List<ParticipantDTO> participants) {
        this.participants = participants;
    }

    public static class ParticipantDTO {
        private String userId;   // 접속이름
        private String nickName; // 별칭

        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }

        public String getNickName() { return nickName; }
        public void setNickName(String nickName) { this.nickName = nickName; }
    }
}
