package com.sodam.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.sodam.entity.ChatRoomHistory;
import com.sodam.repository.ChatRoomHistoryRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.ChatDomain;
import com.sodam.dto.ChatRequest;
import com.sodam.entity.BlockedUser;
import com.sodam.entity.ChatMessage;
import com.sodam.entity.ChatRoom;
import com.sodam.entity.ChatRoomParticipant;
import com.sodam.enums.ChatRoomType;
import com.sodam.repository.BlockedUserRepository;
import com.sodam.repository.ChatMessageRepository;
import com.sodam.repository.ChatRoomParticipantRepository;
import com.sodam.repository.ChatRoomRepository;

@Service
public class ChatService {

    @Autowired
    ChatRoomRepository chatRoomRepository;

    @Autowired
    ChatRoomParticipantRepository participantRepository;

    @Autowired
    ChatMessageRepository chatMessageRepository;

    @Autowired
    BlockedUserRepository blockedUserRepository;

    @Autowired
    ChatRoomHistoryRepository chatRoomHistoryRepository;

    // 채팅방 생성
    public ChatRoom createChatRoom(ChatRequest.CreateRoom request) {
        ChatRoom room = new ChatRoom();
        room.setCreatedBy(request.getCreatedBy());
        room.setType(ChatRoomType.valueOf(request.getType()));
        room.setTitle(request.getTitle());
        room.setCreatedDate(LocalDateTime.now());
        room.setActive(true);

        ChatRoom saved = chatRoomRepository.save(room);

        List<ChatRoomParticipant> participants = new ArrayList<>();
        for (ChatRequest.ParticipantDTO p : request.getParticipants()) {
            ChatRoomParticipant cp = new ChatRoomParticipant();
            cp.setChatRoomId(saved.getId());
            cp.setUserId(p.getUserId());
            cp.setNickName(p.getNickName());
            cp.setJoinedAt(LocalDateTime.now());
            cp.setLastPing(LocalDateTime.now());
            participants.add(cp);
        }

        participantRepository.saveAll(participants);
        return saved;
    }

    // 메시지 전송
    public ChatMessage sendMessage(Long roomId, Long senderId, String message) {
        ChatRoom room = chatRoomRepository.findById(roomId)
            .orElseThrow(() -> new IllegalArgumentException("채팅방이 존재하지 않습니다."));

        List<ChatRoomParticipant> participants = participantRepository.findByChatRoomId(roomId);
        for (ChatRoomParticipant participant : participants) {
            if (!participant.getUserId().equals(senderId) &&
                blockedUserRepository.existsByBlockerIdAndBlockedUserId(participant.getUserId(), senderId)) {
                throw new IllegalStateException("수신자 중 누군가가 보낸 사람을 차단했습니다.");
            }
        }

        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setRoomId(roomId);
        chatMessage.setSenderId(senderId);
        chatMessage.setMessage(message); // ✅ 메시지 저장 누락 주의
        chatMessage.setSentAt(LocalDateTime.now());
        return chatMessageRepository.save(chatMessage);
    }

    public List<ChatMessage> getMessagesByRoom(Long roomId) {
        return chatMessageRepository.findByRoomIdOrderBySentAtAsc(roomId);
    }

    public void blockUser(Long blockerId, Long blockedUserId) {
        if (ChatDomain.isSelfBlock(blockerId, blockedUserId)) {
            throw new IllegalArgumentException("자기 자신을 차단할 수 없습니다.");
        }
        if (!blockedUserRepository.existsByBlockerIdAndBlockedUserId(blockerId, blockedUserId)) {
            blockedUserRepository.save(new BlockedUser(blockerId, blockedUserId));
        }
    }

    // ✅ 채팅방 나가기 + 메시지 삭제
    public void leaveChatRoom(Long chatRoomId, Long userId) {
        List<ChatRoomParticipant> participants = participantRepository.findByChatRoomId(chatRoomId);
        participantRepository.deleteAll(
            participants.stream().filter(p -> p.getUserId().equals(userId)).toList()
        );

        List<ChatRoomParticipant> remaining = participantRepository.findByChatRoomId(chatRoomId);
        if (remaining.isEmpty()) {
            ChatRoom room = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("방이 존재하지 않음"));
            room.setActive(false);
            chatRoomRepository.save(room);

            chatMessageRepository.deleteAllByRoomId(chatRoomId);
        }
    }

    // ✅ 읽음 시간 업데이트
    public void updateReadHistory(Long chatRoomId, Long userId, String data) {
        ChatRoomHistory history = chatRoomHistoryRepository
            .findByChatRoomNoAndUserId(chatRoomId, userId)
            .orElse(new ChatRoomHistory());

        history.setChatRoomNo(chatRoomId);
        history.setUserId(userId);
        history.setReceiveData(data);
        history.setLastModifiedDate(LocalDateTime.now());

        if (history.getCreatedDate() == null) {
            history.setCreatedDate(LocalDateTime.now());
        }

        chatRoomHistoryRepository.save(history);
    }

    // ✅ 접속 ping 업데이트
    public void updateLastPing(Long roomId, Long userId) {
        List<ChatRoomParticipant> participants = participantRepository.findByChatRoomId(roomId);
        for (ChatRoomParticipant p : participants) {
            if (p.getUserId().equals(userId)) {
                p.setLastPing(LocalDateTime.now());
                participantRepository.save(p);
                break;
            }
        }
    }

    // ✅ 현재 접속 중인 인원
    public List<ChatRoomParticipant> getOnlineUsers(Long roomId) {
        LocalDateTime recent = LocalDateTime.now().minusMinutes(5);
        return participantRepository.findOnlineUsers(roomId, recent);
    }
    public ChatMessage syncMessage(ChatRequest.SyncMessage request) {
        if (chatMessageRepository.existsByUuid(request.getUuid())) {
            throw new IllegalStateException("이미 동기화된 메시지입니다.");
        }

        ChatMessage msg = new ChatMessage();
        msg.setRoomId(request.getRoomId());
        msg.setSenderId(request.getSenderId());
        msg.setMessage(request.getMessage());
        msg.setUuid(request.getUuid());
        msg.setSentAt(request.getSentAt());
        msg.setOrigin("bluetooth");

        return chatMessageRepository.save(msg);
    }

}
