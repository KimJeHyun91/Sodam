package com.sodam.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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
}
