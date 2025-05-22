package com.sodam.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.List;

public class ChatRequest {

    @Data
    public static class CreateRoom {
        @NotNull
        private Long createdBy;

        @NotNull
        private String type;

        private String title;

        private List<ParticipantDTO> participants;
    }

    @Data
    public static class ParticipantDTO {
        @NotNull
        private Long userId;
        private String nickName;
    }

    @Data
    public static class SendMessage {
        @NotNull
        private Long roomId;
        @NotNull
        private Long senderId;
        @NotNull
        private String message;
    }

    @Data
    public static class BlockUser {
        @NotNull
        private Long blockerId;
        @NotNull
        private Long blockedUserId;
    }

    @Data
    public static class MuteUser {
        @NotNull
        private Long muterId;
        @NotNull
        private Long mutedUserId;
    }
}
