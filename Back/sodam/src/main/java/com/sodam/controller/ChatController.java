package com.sodam.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sodam.dto.ChatRequest;
import com.sodam.entity.ChatMessage;
import com.sodam.entity.ChatRoom;
import com.sodam.entity.ChatRoomParticipant;
import com.sodam.service.ChatService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/chat")
public class ChatController {

    @Autowired
    private ChatService chatService;

    // 채팅방 생성
    @PostMapping("/room")
    public ResponseEntity<Integer> createRoom(@RequestBody @Valid ChatRequest.CreateRoom request) {
        try {
            ChatRoom room = chatService.createChatRoom(request);
            return ResponseEntity.ok(room != null ? 1400 : 1401);
        } catch (Exception e) {
            return ResponseEntity.ok(1401);
        }
    }

    // 메시지 전송
    @PostMapping("/message")
    public ResponseEntity<Integer> sendMessage(@RequestBody @Valid ChatRequest.SendMessage request) {
        try {
            ChatMessage message = chatService.sendMessage(request.getRoomId(), request.getSenderId(), request.getMessage());
            return ResponseEntity.ok(message != null ? 1410 : 1411);
        } catch (Exception e) {
            return ResponseEntity.ok(1411);
        }
    }

    // 채팅 내역 조회
    @GetMapping("/room/{roomId}/messages")
    public ResponseEntity<?> getMessages(@PathVariable Long roomId) {
        try {
            List<ChatMessage> messages = chatService.getMessagesByRoom(roomId);
            return ResponseEntity.ok(messages != null ? messages : 1421);
        } catch (Exception e) {
            return ResponseEntity.ok(1421);
        }
    }

    // 유저 차단
    @PostMapping("/block")
    public ResponseEntity<Integer> blockUser(@RequestBody @Valid ChatRequest.BlockUser request) {
        try {
            chatService.blockUser(request.getBlockerId(), request.getBlockedUserId());
            return ResponseEntity.ok(1430);
        } catch (Exception e) {
            return ResponseEntity.ok(1431);
        }
    }

    // 채팅방 나가기
    @PostMapping("/room/leave")
    public ResponseEntity<Integer> leaveRoom(@RequestParam Long roomId, @RequestParam Long userId) {
        try {
            chatService.leaveChatRoom(roomId, userId);
            return ResponseEntity.ok(1450);
        } catch (Exception e) {
            return ResponseEntity.ok(1451);
        }
    }

    // 읽음 처리
    @PostMapping("/room/read")
    public ResponseEntity<Integer> readRoom(@RequestParam Long roomId, @RequestParam Long userId) {
        try {
            chatService.updateReadHistory(roomId, userId, "읽음");
            return ResponseEntity.ok(1440);
        } catch (Exception e) {
            return ResponseEntity.ok(1441);
        }
    }

    // 접속자 확인
    @GetMapping("/room/{roomId}/online-users")
    public ResponseEntity<?> getOnlineUsers(@PathVariable Long roomId) {
        try {
            List<ChatRoomParticipant> users = chatService.getOnlineUsers(roomId);
            return ResponseEntity.ok(users != null ? users : 1461);
        } catch (Exception e) {
            return ResponseEntity.ok(1461);
        }
    }
 // Bluetooth 메시지 동기화
    @PostMapping("/message/sync")
    public ResponseEntity<Integer> syncBluetoothMessage(@RequestBody @Valid ChatRequest.SyncMessage request) {
        try {
            chatService.syncMessage(request);
            return ResponseEntity.ok(1470);
        } catch (Exception e) {
            return ResponseEntity.ok(1471);
        }
    }

}
