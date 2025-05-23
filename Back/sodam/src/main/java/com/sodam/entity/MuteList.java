package com.sodam.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MuteList {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long muterId;
    private Long mutedUserId;

    
    public MuteList(Long muterId, Long mutedUserId) {
        this.muterId = muterId;
        this.mutedUserId = mutedUserId;
    }
}
