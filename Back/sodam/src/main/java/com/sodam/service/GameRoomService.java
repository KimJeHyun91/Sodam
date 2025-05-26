package com.sodam.service;

import com.sodam.dto.GameRoomRequest;
import com.sodam.dto.GameRoomResponse;
import com.sodam.entity.GameRoom;
import com.sodam.entity.GameRoomParticipant;
import com.sodam.enums.GameType;
import com.sodam.repository.GameRoomRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GameRoomService {

    private final GameRoomRepository gameRoomRepository;

    public GameRoomService(GameRoomRepository gameRoomRepository) {
        this.gameRoomRepository = gameRoomRepository;
    }

    public GameRoom createRoom(String gameType, List<GameRoomRequest.ParticipantDTO> participantsDTO) {
        if (participantsDTO == null || participantsDTO.size() < 2 || participantsDTO.size() > 7) {
            throw new IllegalArgumentException("게임 참가자는 최소 2명, 최대 7명이어야 합니다.");
        }

        GameRoom gameRoom = new GameRoom();
        try {
            GameType type = GameType.valueOf(gameType.toUpperCase());
            gameRoom.setGameType(type);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("잘못된 게임 타입입니다: " + gameType);
        }

        List<GameRoomParticipant> participants = new ArrayList<>();
        for (GameRoomRequest.ParticipantDTO dto : participantsDTO) {
            GameRoomParticipant participant = new GameRoomParticipant();
            participant.setUserId(dto.getUserId());
            participant.setNickName(dto.getNickName());
            participant.setGameRoom(gameRoom);
            participants.add(participant);
        }

        gameRoom.setParticipants(participants);
        return gameRoomRepository.save(gameRoom);
    }

    public GameRoomResponse getRoomDetail(Long roomId) {
        GameRoom room = gameRoomRepository.findById(roomId)
            .orElseThrow(() -> new IllegalArgumentException("해당 게임방이 존재하지 않습니다."));

        List<String> nickNames = room.getParticipants().stream()
            .map(GameRoomParticipant::getNickName)
            .collect(Collectors.toList());

        return new GameRoomResponse(
            room.getId(),
            room.getGameType(),
            room.getCreatedDate(),
            nickNames
        );
    }

    public List<GameRoomResponse> getAllRooms() {
        return gameRoomRepository.findAll().stream()
            .map(room -> new GameRoomResponse(
                room.getId(),
                room.getGameType(),
                room.getCreatedDate(),
                room.getParticipants().stream()
                    .map(GameRoomParticipant::getNickName)
                    .collect(Collectors.toList())
            ))
            .collect(Collectors.toList());
    }
}
