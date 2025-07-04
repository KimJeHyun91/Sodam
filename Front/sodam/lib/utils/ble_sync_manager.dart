import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sodam/utils/local_ble_store.dart';
import 'package:sodam/chat/chat_service.dart';

class BleSyncManager {
  static final BleSyncManager _instance = BleSyncManager._internal();
  factory BleSyncManager() => _instance;

  BleSyncManager._internal();

  StreamSubscription<ConnectivityResult>? _subscription;

  void startMonitoring() {
    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncPendingMessages();
      }
    });
  }

  Future<void> _syncPendingMessages() async {
    final unsynced = await LocalBleStore.loadAll();
    if (unsynced.isEmpty) return;

    for (final msg in unsynced) {
      try {
        await ChatService.syncBleMessageToServer(
          roomId: msg['roomId'],
          message: msg['message'],
          uuid: msg['uuid'],
          senderId: msg['senderId'],
          sentAt: msg['sentAt'],
        );
      } catch (_) {
        // 실패한 메시지는 남겨둠
      }
    }

    // 전송 후 메시지 초기화
    await LocalBleStore.clear();
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }
}
