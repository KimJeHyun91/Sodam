package com.sodam.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class PointSocketController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public void sendPointUpdate(String userId, int newPoint) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("userId", userId);
        payload.put("currentPoint", newPoint);

        messagingTemplate.convertAndSend("/topic/point/" + userId, payload);
    }
}