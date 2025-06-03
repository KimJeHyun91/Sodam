package com.sodam.service;

import com.sodam.entity.BlockedUser;
import com.sodam.repository.BlockedUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BlockedUserService {

    @Autowired
    private BlockedUserRepository blockedUserRepository;

   
    public BlockedUser blockUser(String blockerId, String blockedUserId) {
        if (!blockedUserRepository.existsByBlockerIdAndBlockedUserId(blockerId, blockedUserId)) {
            return blockedUserRepository.save(new BlockedUser(blockerId, blockedUserId));
        }
        return null;
    }

    
    public List<BlockedUser> getBlockedUsers(String blockerId) {
        return blockedUserRepository.findAll().stream()
                .filter(b -> b.getBlockerId().equals(blockerId))
                .toList();
    }

    
    public boolean unblockUser(String blockerId, String blockedUserId) {
        List<BlockedUser> all = blockedUserRepository.findAll();
        return all.stream()
            .filter(b -> b.getBlockerId().equals(blockerId) && b.getBlockedUserId().equals(blockedUserId))
            .findFirst()
            .map(blockedUser -> {
                blockedUserRepository.delete(blockedUser);
                return true;
            }).orElse(false);
    }

    
    public boolean isBlocked(String blockerId, String blockedUserId) {
        return blockedUserRepository.existsByBlockerIdAndBlockedUserId(blockerId, blockedUserId);
    }
}
