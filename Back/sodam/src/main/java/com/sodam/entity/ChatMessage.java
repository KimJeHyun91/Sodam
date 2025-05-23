package com.sodam.entity;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class ChatMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long roomId;
    private Long senderId;
    private String message;
    private LocalDateTime sentAt;

    @Column(unique = true)
    private String uuid; // 블루투스 메시지 고유 식별자

    private String origin; // 예: "bluetooth" or "server"
}

