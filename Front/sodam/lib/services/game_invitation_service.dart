import 'dart:async';
import '../services/bluetooth_service.dart';

class GameInvitationService {
  final BluetoothService _bluetoothService;
  final Map<String, bool> _responses = {}; // id -> 수락 여부
  void Function()? onAllAccepted;
  void Function(String)? onRejected;

  GameInvitationService(this._bluetoothService);

  /// ✅ 초대 메시지를 보냄
  Future<void> sendInvitations(List<String> userIds) async {
    for (var id in userIds) {
      final message = 'INVITE';
      await _bluetoothService.sendMessageTo(id, message);
      _responses[id] = false; // 초기 상태
    }
  }

  /// ✅ 메시지 수신 후 응답 처리
  void listenForResponses() {
    _bluetoothService.listenToMessages((String raw) {
      final parts = raw.split(':');
      if (parts.length != 2) return;

      final senderId = parts[0];
      final message = parts[1];

      if (message == 'ACCEPT') {
        _responses[senderId] = true;
        _checkAllAccepted();
      } else if (message == 'DECLINE') {
        onRejected?.call(senderId);
      }
    });
  }

  void _checkAllAccepted() {
    if (_responses.values.every((accepted) => accepted)) {
      onAllAccepted?.call();
    }
  }

  void setOnAllAccepted(void Function() callback) {
    onAllAccepted = callback;
  }

  void setOnRejected(void Function(String) callback) {
    onRejected = callback;
  }

  Future<void> sendResponse(String response, String myId) async {
    await _bluetoothService.sendMessage("$myId:$response");
  }
}
