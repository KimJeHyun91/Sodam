package com.sodam.domain;

public class ChatDomain {
    public static boolean isSelfBlock(Long blockerId, Long blockedUserId) {
        return blockerId.equals(blockedUserId);
    }

    public static boolean isSelfMute(Long muterId, Long mutedUserId) {
        return muterId.equals(mutedUserId);
    }
}
