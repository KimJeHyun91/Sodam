package com.sodam.entity;

import com.sodam.enums.ChatRoomType;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String createdBy; // String으로 변경 (접속이름)

    private String title;

    @Enumerated(EnumType.STRING)
    private ChatRoomType type;

    private LocalDateTime createdDate;

    private boolean active = true;
}

