package com.sodam.controller;

import com.sodam.dto.GameRoomRequest;
import com.sodam.dto.GameRoomResponse;
import com.sodam.service.GameRoomService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/gameroom")
public class GameRoomController {

    private final GameRoomService gameRoomService;

    public GameRoomController(GameRoomService gameRoomService) {
        this.gameRoomService = gameRoomService;
    }

    // 게임방 생성
    @PostMapping("/create")
    public ResponseEntity<Integer> createRoom(@RequestBody GameRoomRequest request) {
        try {
            gameRoomService.createRoom(request.getGameType(), request.getNickNames());
            return ResponseEntity.ok(1300); // 성공
        } catch (Exception e) {
            return ResponseEntity.ok(1301); // 실패
        }
    }

    // 게임방 상세 조회
    @GetMapping("/detail")
    public ResponseEntity<?> getRoomDetail(@RequestParam Long roomId) {
        try {
            GameRoomResponse response = gameRoomService.getRoomDetail(roomId);
            return ResponseEntity.ok(response); // 데이터 반환
        } catch (Exception e) {
            return ResponseEntity.ok(1302); // 실패
        }
    }

    // 전체 게임방 목록 조회
    @GetMapping("/list")
    public ResponseEntity<?> listRooms() {
        try {
            List<GameRoomResponse> responses = gameRoomService.getAllRooms();
            return ResponseEntity.ok(responses); // 데이터 반환
        } catch (Exception e) {
            return ResponseEntity.ok(1303); // 실패
        }
    }
}
