import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;

class BluetoothService extends ChangeNotifier {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  bool _isAdvertising = false;
  bool _isScanning = false;

  final Map<String, flutter_blue.BluetoothDevice> _connectedDevices = {};
  final Map<String, flutter_blue.BluetoothCharacteristic> _writeChars = {};
  List<flutter_blue.ScanResult> _cachedResults = [];

  StreamSubscription? _scanSubscription;
  void Function(String message)? _onMessageReceived;

  void listenToMessages(void Function(String message) callback) {
    _onMessageReceived = callback;
  }

  Future<void> initBluetooth() async {
    await stopAll();
    await Future.delayed(const Duration(milliseconds: 300));
    await startAdvertising();
    await startScanning(duration: const Duration(seconds: 60));
    _cacheScanResults();
  }

  void _cacheScanResults() {
    _scanSubscription?.cancel();
    _scanSubscription = scanResults.listen((results) {
      _cachedResults = results;
      notifyListeners();
    });
  }

  Future<void> stopAll() async {
    _scanSubscription?.cancel();
    if (_isAdvertising) {
      await _blePeripheral.stop();
      _isAdvertising = false;
      print("🛑 광고 중지됨");
    }
    if (_isScanning) {
      await flutter_blue.FlutterBluePlus.stopScan();
      _isScanning = false;
      print("🛑 스캔 중지됨");
    }
  }

  Future<void> startAdvertising() async {
    if (_isAdvertising) return;

    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      serviceUuid: '12345678-1234-1234-1234-567890123456',
      manufacturerId: 777,
      manufacturerData: Uint8List.fromList(utf8.encode("sodam")),
    );

    await _blePeripheral.start(advertiseData: advertiseData);
    _isAdvertising = true;
    print("📢 광고 시작됨 (sodam)");
  }

  Future<void> startScanning({Duration? duration}) async {
    if (_isScanning) return;

    await flutter_blue.FlutterBluePlus.startScan(timeout: duration);
    _isScanning = true;
    print("🔍 스캔 시작됨 (${duration?.inSeconds ?? 0}초)");
  }

  Stream<List<flutter_blue.ScanResult>> get scanResults =>
      flutter_blue.FlutterBluePlus.scanResults;

  Future<bool> connectToDeviceById(String receiverId, {int retryCount = 2}) async {
    for (int attempt = 0; attempt <= retryCount; attempt++) {
      try {
        if (_connectedDevices.containsKey(receiverId)) {
          print("🔗 [$receiverId] 이미 연결됨");
          return true;
        }

        final scanResult = _cachedResults.firstWhere(
              (r) => r.device.remoteId.str == receiverId,
          orElse: () => throw Exception("❌ [$receiverId] 디바이스를 찾을 수 없음"),
        );

        final device = scanResult.device;
        print("🟡 [$receiverId] 연결 시도 중... (시도 ${attempt + 1})");

        await device.connect(autoConnect: false)
            .timeout(const Duration(seconds: 20));
        _connectedDevices[receiverId] = device;

        final services = await device.discoverServices();
        for (var service in services) {
          for (var char in service.characteristics) {
            if (char.properties.write) {
              _writeChars[receiverId] = char;
            }
            if (char.properties.notify) {
              await char.setNotifyValue(true);
              char.lastValueStream.listen((value) {
                final msg = utf8.decode(value);
                print("📩 [$receiverId] 수신됨: $msg");
                if (_onMessageReceived != null) {
                  _onMessageReceived!(msg);
                }
              });
            }
          }
        }

        print("✅ [$receiverId] 연결 성공");
        return true;
      } catch (e) {
        print("⚠️ [$receiverId] 연결 실패 (시도 ${attempt + 1}): $e");
        if (attempt == retryCount) {
          print("❌ [$receiverId] 재시도 종료: 연결 실패");
          return false;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return false;
  }

  Future<void> sendMessageTo(String receiverId, String message) async {
    print("📡 [$receiverId]에게 메시지 전송 시도: $message");

    try {
      final connected = await connectToDeviceById(receiverId);
      if (!connected) return;

      final writeChar = _writeChars[receiverId];
      if (writeChar == null) {
        print("❌ [$receiverId] 쓰기 특성 없음");
        return;
      }

      final data = utf8.encode(message);
      await writeChar.write(data, withoutResponse: true);
      print("📤 [$receiverId] 메시지 전송 완료: $message");
    } catch (e) {
      print("⚠️ [$receiverId] 전송 실패: $e");
    }
  }

  Future<void> broadcastMessage(List<String> receiverIds, String message) async {
    for (final id in receiverIds) {
      await sendMessageTo(id, message);
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> disconnectAll() async {
    for (final device in _connectedDevices.values) {
      await device.disconnect();
    }
    _connectedDevices.clear();
    _writeChars.clear();
    print("🔌 모든 기기 연결 해제됨");
  }
}
