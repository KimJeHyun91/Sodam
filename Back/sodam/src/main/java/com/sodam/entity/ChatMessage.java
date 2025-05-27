package com.sodam.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long roomId;

    private String senderId;

    private String message;

    @Column(unique = true)
    private String uuid; // 메시지 중복 방지용 (Bluetooth sync 대비)

    private String origin; // e.g., "bluetooth" or "server"

    private LocalDateTime sentAt;
}

