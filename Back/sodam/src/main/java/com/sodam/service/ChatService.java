package com.sodam.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sodam.domain.ChatDomain;
import com.sodam.entity.BlockedUser;
import com.sodam.entity.ChatMessage;
import com.sodam.entity.ChatRoom;
import com.sodam.entity.MuteList;
import com.sodam.repository.BlockedUserRepository;
import com.sodam.repository.ChatMessageRepository;
import com.sodam.repository.ChatRoomRepository;
import com.sodam.repository.MuteListRepository;

@Service
public class ChatService {
    @Autowired
    ChatRoomRepository chatRoomRepository;

    @Autowired
    ChatMessageRepository chatMessageRepository;

    @Autowired
    BlockedUserRepository blockedUserRepository;

    @Autowired
    MuteListRepository muteListRepository;

    public ChatRoom createChatRoom(Long userAId, Long userBId) {
        ChatRoom room = new ChatRoom();
        room.setUserAId(userAId);
        room.setUserBId(userBId);
        return chatRoomRepository.save(room);
    }

    public List<ChatRoom> getChatRoomsForUser(Long userId) {
        return chatRoomRepository.findByUserAIdOrUserBId(userId, userId);
    }

    public ChatMessage sendMessage(Long roomId, Long senderId, String message) {
        ChatRoom room = chatRoomRepository.findById(roomId)
            .orElseThrow(() -> new IllegalArgumentException("채팅방이 존재하지 않습니다."));
        Long receiverId = senderId.equals(room.getUserAId()) ? room.getUserBId() : room.getUserAId();

        if (blockedUserRepository.existsByBlockerIdAndBlockedUserId(receiverId, senderId)) {
            throw new IllegalStateException("수신자가 보낸 사람을 차단했습니다.");
        }

        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setRoomId(roomId);
        chatMessage.setSenderId(senderId);
        chatMessage.setMessage(message);
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
            BlockedUser blockedUser = new BlockedUser(blockerId, blockedUserId);
            blockedUserRepository.save(blockedUser);
        }
    }

    public void muteUser(Long muterId, Long mutedUserId) {
        if (ChatDomain.isSelfMute(muterId, mutedUserId)) {
            throw new IllegalArgumentException("자기 자신을 음소거할 수 없습니다.");
        }
        if (!muteListRepository.existsByMuterIdAndMutedUserId(muterId, mutedUserId)) {
            MuteList muteList = new MuteList(muterId, mutedUserId);
            muteListRepository.save(muteList);
        }
    }
}
