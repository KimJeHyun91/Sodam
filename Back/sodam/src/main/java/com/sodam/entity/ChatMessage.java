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
    private String senderId;
    private String message;
    private LocalDateTime sentAt;

    @Column(unique = true)
    private String uuid;

    private String origin;
}
