package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.sodam.entity.BlockedUser;

public interface BlockedUserRepository extends JpaRepository<BlockedUser, Long> {
    boolean existsByBlockerIdAndBlockedUserId(String blockerId, String blockedUserId);
    @Modifying
    @Query("DELETE FROM BlockedUser b WHERE b.blockerId = :blockerId AND b.blockedUserId = :blockedUserId")
    void deleteByBlockerIdAndBlockedUserId(@Param("blockerId") String blockerId, @Param("blockedUserId") String blockedUserId);
    
    
}
