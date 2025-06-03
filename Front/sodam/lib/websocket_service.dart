import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  static StompClient? stompClient;

  static void connect({
    required String userId,
    required Function(int) onPointUpdate,
  }) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://<서버_IP>:<포트>/ws', // 예: http://192.168.0.3:8080/ws
        onConnect: (StompFrame frame) {
          print('WebSocket 연결됨');

          stompClient!.subscribe(
            destination: '/topic/point/$userId',
            callback: (frame) {
              final data = jsonDecode(frame.body!);
              final int newPoint = data['currentPoint'];
              onPointUpdate(newPoint); // 지갑 업데이트 트리거
            },
          );
        },
        onWebSocketError: (error) => print('❌ WebSocket 오류: $error'),
      ),
    );

    stompClient!.activate();
  }

  static void disconnect() {
    stompClient?.deactivate();
  }
}