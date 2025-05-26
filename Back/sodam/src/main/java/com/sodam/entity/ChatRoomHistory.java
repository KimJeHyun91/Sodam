package com.sodam.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long chatRoomNo;
    private String userId; // 접속이름

    private String receiveData;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;
}
	