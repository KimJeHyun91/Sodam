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

    private Long blockerId;
    private Long blockedUserId;

  
    public BlockedUser(Long blockerId, Long blockedUserId) {
        this.blockerId = blockerId;
        this.blockedUserId = blockedUserId;
    }
}
