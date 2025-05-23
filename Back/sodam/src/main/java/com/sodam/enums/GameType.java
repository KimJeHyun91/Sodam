package com.sodam.enums;

public enum GameType {
    DDAKJI("딱지치기"),
    SANGAJI("산가지"),
    NAMSUNGDO("남숭도");

    private final String displayName;

    GameType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
