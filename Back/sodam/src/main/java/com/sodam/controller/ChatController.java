package com.sodam.controller;

import com.sodam.dto.ChatRequest;
import com.sodam.entity.ChatMessage;
import com.sodam.entity.ChatRoom;
import com.sodam.service.ChatService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chat")
public class ChatController {

    @Autowired
    private ChatService chatService;

    @PostMapping("/room")
    public ResponseEntity<Integer> createRoom(@RequestBody @Valid ChatRequest.CreateRoom request) {
        try {
            ChatRoom room = chatService.createChatRoom(request);
            return ResponseEntity.ok(room != null ? 2000 : 2001);
        } catch (Exception e) {
            return ResponseEntity.ok(2001);
        }
    }

    @PostMapping("/message")
    public ResponseEntity<Integer> sendMessage(@RequestBody @Valid ChatRequest.SendMessage request) {
        try {
            ChatMessage message = chatService.sendMessage(request.getRoomId(), request.getSenderId(), request.getMessage());
            return ResponseEntity.ok(message != null ? 2010 : 2011);
        } catch (Exception e) {
            return ResponseEntity.ok(2011);
        }
    }

    @GetMapping("/room/{roomId}/messages")
    public ResponseEntity<?> getMessages(@PathVariable Long roomId) {
        try {
            List<ChatMessage> messages = chatService.getMessagesByRoom(roomId);
            return ResponseEntity.ok(messages != null ? messages : 2021);
        } catch (Exception e) {
            return ResponseEntity.ok(2021);
        }
    }

    @PostMapping("/block")
    public ResponseEntity<Integer> blockUser(@RequestBody @Valid ChatRequest.BlockUser request) {
        try {
            chatService.blockUser(request.getBlockerId(), request.getBlockedUserId());
            return ResponseEntity.ok(2030);
        } catch (Exception e) {
            return ResponseEntity.ok(2031);
        }
    }


    @PostMapping("/room/leave")
    public ResponseEntity<Integer> leaveRoom(@RequestParam Long roomId, @RequestParam Long userId) {
        try {
            chatService.leaveChatRoom(roomId, userId);
            return ResponseEntity.ok(2050);
        } catch (Exception e) {
            return ResponseEntity.ok(2051);
        }
    }
}
