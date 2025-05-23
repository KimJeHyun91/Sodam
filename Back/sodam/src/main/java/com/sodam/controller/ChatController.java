package com.sodam.controller;

import java.util.List;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.sodam.dto.ChatRequest;
import com.sodam.entity.ChatMessage;
import com.sodam.entity.ChatRoom;
import com.sodam.service.ChatService;

@RestController
@RequestMapping("/chat")
public class ChatController {
    @Autowired
    ChatService chatService;

    @PostMapping("/room")
    public ResponseEntity<ChatRoom> createRoom(@RequestBody @Valid ChatRequest.CreateRoom request) {
        return ResponseEntity.ok(chatService.createChatRoom(request.getUserAId(), request.getUserBId()));
    }

    @GetMapping("/rooms/{userId}")
    public ResponseEntity<List<ChatRoom>> getRooms(@PathVariable Long userId) {
        return ResponseEntity.ok(chatService.getChatRoomsForUser(userId));
    }

    @PostMapping("/message")
    public ResponseEntity<ChatMessage> sendMessage(@RequestBody @Valid ChatRequest.SendMessage request) {
        return ResponseEntity.ok(chatService.sendMessage(request.getRoomId(), request.getSenderId(), request.getMessage()));
    }

    @GetMapping("/room/{roomId}/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(@PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getMessagesByRoom(roomId));
    }

    @PostMapping("/block")
    public ResponseEntity<Void> blockUser(@RequestBody @Valid ChatRequest.BlockUser request) {
        chatService.blockUser(request.getBlockerId(), request.getBlockedUserId());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/mute")
    public ResponseEntity<Void> muteUser(@RequestBody @Valid ChatRequest.MuteUser request) {
        chatService.muteUser(request.getMuterId(), request.getMutedUserId());
        return ResponseEntity.ok().build();
    }
}
