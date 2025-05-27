package com.sodam.dto;

import java.time.LocalDateTime;
import java.util.List;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

public class ChatRequest {

    @Data
    public static class CreateRoom {
        @NotNull
        private String createdBy; // 접속이름

        @NotNull
        private String type;

        private String title;

        private List<ParticipantDTO> participants;
    }

    @Data
    public static class ParticipantDTO {
        @NotNull
        private String userId; // 접속이름
        @NotNull
        private String nickName;
    }

    @Data
    public static class SendMessage {
        @NotNull
        private Long roomId;
        @NotNull
        private String senderId;
        @NotNull
        private String message;
    }

    @Data
    public static class BlockUser {
        @NotNull
        private String blockerId;
        @NotNull
        private String blockedUserId;
    }

    @Data
    public static class MuteUser {
        @NotNull
        private String muterId;
        @NotNull
        private String mutedUserId;
    }

    @Data
    public static class SyncMessage {
        @NotNull
        private Long roomId;

        @NotNull
        private String senderId;

        @NotNull
        private String message;

        @NotNull
        private String uuid;

        @NotNull
        private LocalDateTime sentAt;
    }
}
