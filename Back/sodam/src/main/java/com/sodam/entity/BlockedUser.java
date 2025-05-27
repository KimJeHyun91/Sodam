package com.sodam.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BlockedUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String blockerId;
    private String blockedUserId;

    public BlockedUser(String blockerId, String blockedUserId) {
        this.blockerId = blockerId;
        this.blockedUserId = blockedUserId;
    }
}
