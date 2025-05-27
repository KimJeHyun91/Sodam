package com.sodam.domain;

public class ChatDomain {
    public static boolean isSelfBlock(String blockerId, String blockedUserId) {
        return blockerId.equals(blockedUserId);
    }

    public static boolean isSelfMute(String muterId, String mutedUserId) {
        return muterId.equals(mutedUserId);
    }
}
