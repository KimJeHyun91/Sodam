package com.sodam.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

public class ChatRequest {

    @Data
    public static class CreateRoom {
        @NotNull
        private Long userAId;
        @NotNull
        private Long userBId;
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
