package com.sodam.repository;

import com.sodam.entity.BlockedUser;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BlockedUserRepository extends JpaRepository<BlockedUser, Long> {
    boolean existsByBlockerIdAndBlockedUserId(String blockerId, String blockedUserId);
}
