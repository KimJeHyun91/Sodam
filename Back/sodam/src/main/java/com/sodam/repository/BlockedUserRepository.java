package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.sodam.entity.BlockedUser;

public interface BlockedUserRepository extends JpaRepository<BlockedUser, Long> {
    boolean existsByBlockerIdAndBlockedUserId(Long blockerId, Long blockedUserId);
}
