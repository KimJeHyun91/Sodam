import 'dart:async';
import '../services/bluetooth_service.dart';

class GameInvitationService {
  final BluetoothService _bluetoothService;
  final Map<String, bool> _responses = {}; // 각 유저 ID -> 수락 여부
  final StreamController<String> _messageStreamController = StreamController.broadcast();

  // 콜백
  void Function()? onAllAccepted;
  void Function(String)? onRejected;

  GameInvitationService(this._bluetoothService) {
    // BluetoothService에서 메시지 수신 시 처리 연결
    _bluetoothService.listenToMessages(_handleIncomingMessage);
  }

  /// ✅ 초대 메시지 전송
  Future<void> sendInvitations(List<String> userIds) async {
    for (var id in userIds) {
      final message = 'HOST:INVITE';
      try {
        print("📨 [$id]에게 초대 전송 중...");
        await _bluetoothService.sendMessageTo(id, message);
        _responses[id] = false; // 기본 수락 안함으로 등록
      } catch (e) {
        print("❌ [$id] 전송 실패: $e");
      }
    }
  }

  /// ✅ 수신 메시지 처리
  void _handleIncomingMessage(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) {
      print("⚠️ 메시지 포맷 오류: $raw");
      return;
    }

    final senderId = parts[0];
    final message = parts[1];

    print("📥 [$senderId] → 메시지 수신: $message");

    switch (message) {
      case 'ACCEPT':
        _responses[senderId] = true;
        _checkAllAccepted();
        break;

      case 'DECLINE':
        onRejected?.call(senderId);
        break;

      default:
        if (message.startsWith('START')) {
          _messageStreamController.add(raw); // START 메시지는 캐릭터 페이지에서 사용
        }
        break;
    }
  }

  /// ✅ 모든 참가자가 수락했는지 확인
  void _checkAllAccepted() {
    if (_responses.isNotEmpty && _responses.values.every((v) => v)) {
      print("✅ 모든 유저 수락 완료");
      onAllAccepted?.call();
    }
  }

  /// ✅ 캐릭터 페이지에서 수신하는 START 스트림
  Stream<String> get onMessage => _messageStreamController.stream;

  /// ✅ 콜백 등록 메서드들
  void setOnAllAccepted(void Function() callback) {
    onAllAccepted = callback;
  }

  void setOnRejected(void Function(String) callback) {
    onRejected = callback;
  }

  /// ✅ 응답 메시지 전송
  Future<void> sendResponse(String response, String targetId) async {
    final message = "$targetId:$response";
    await _bluetoothService.sendMessageTo(targetId, response);
    print("📤 $response 메시지 전송됨 → $targetId");
  }

  /// ✅ 리소스 해제
  void dispose() {
    _messageStreamController.close();
  }
}
