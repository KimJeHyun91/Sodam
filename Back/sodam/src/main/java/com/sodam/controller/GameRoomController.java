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

    @PostMapping("/create")
    public ResponseEntity<Integer> createRoom(@RequestBody GameRoomRequest request) {
        try {
            gameRoomService.createRoom(request.getGameType(), request.getParticipants());
            return ResponseEntity.ok(1300);
        } catch (Exception e) {
            return ResponseEntity.ok(1301);
        }
    }

    @GetMapping("/detail")
    public ResponseEntity<?> getRoomDetail(@RequestParam Long roomId) {
        try {
            GameRoomResponse response = gameRoomService.getRoomDetail(roomId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.ok(1302);
        }
    }

    @GetMapping("/list")
    public ResponseEntity<?> listRooms() {
        try {
            List<GameRoomResponse> responses = gameRoomService.getAllRooms();
            return ResponseEntity.ok(responses);
        } catch (Exception e) {
            return ResponseEntity.ok(1303);
        }
    }
}
