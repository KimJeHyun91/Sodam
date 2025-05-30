package com.sodam.controller;

import com.sodam.entity.BlockedUser;
import com.sodam.service.BlockedUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/block")
public class BlockedUserController {

    @Autowired
    private BlockedUserService blockedUserService;

    
    @PostMapping
    public ResponseEntity<?> blockUser(@RequestParam String blockerId, @RequestParam String blockedUserId) {
        BlockedUser result = blockedUserService.blockUser(blockerId, blockedUserId);
        if (result != null) {
            return ResponseEntity.ok("차단 완료");
        } else {
            return ResponseEntity.badRequest().body("이미 차단됨");
        }
    }

    
    @DeleteMapping
    public ResponseEntity<?> unblockUser(@RequestParam String blockerId, @RequestParam String blockedUserId) {
        boolean result = blockedUserService.unblockUser(blockerId, blockedUserId);
        if (result) {
            return ResponseEntity.ok("차단 해제됨");
        } else {
            return ResponseEntity.badRequest().body("차단 해제 실패");
        }
    }

   
    @GetMapping("/{blockerId}")
    public ResponseEntity<List<BlockedUser>> getBlockedUsers(@PathVariable String blockerId) {
        return ResponseEntity.ok(blockedUserService.getBlockedUsers(blockerId));
    }

  
    @GetMapping("/is-blocked")
    public ResponseEntity<Boolean> isBlocked(@RequestParam String blockerId, @RequestParam String blockedUserId) {
        return ResponseEntity.ok(blockedUserService.isBlocked(blockerId, blockedUserId));
    }
}
