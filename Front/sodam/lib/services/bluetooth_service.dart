// 📁 lib/services/bluetooth_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;

import 'permission_request.dart'; // ✅ 권한 요청 포함

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  bool _isAdvertising = false;
  bool _isScanning = false;

  flutter_blue.BluetoothDevice? _connectedDevice;
  flutter_blue.BluetoothCharacteristic? _writeChar;
  flutter_blue.BluetoothCharacteristic? _notifyChar;

  final Map<String, flutter_blue.BluetoothCharacteristic> _writeCharMap = {};
  final Map<String, flutter_blue.BluetoothCharacteristic> _notifyCharMap = {};
  StreamSubscription<List<int>>? _notifySubscription;

  final _discoveredDevices = <flutter_blue.BluetoothDevice>[];
  final _deviceStreamController =
  StreamController<List<flutter_blue.BluetoothDevice>>.broadcast();

  Stream<List<flutter_blue.BluetoothDevice>> get discoveredDevices =>
      _deviceStreamController.stream;

  flutter_blue.BluetoothCharacteristic? get writeChar => _writeChar;
  flutter_blue.BluetoothCharacteristic? get notifyChar => _notifyChar;

  /// Bluetooth 초기화: UUID를 받아 광고/스캔 시작
  Future<void> initBluetooth(String uuid) async {
    await requestBluetoothPermissions(); // 권한 요청
    await stopAll();
    await Future.delayed(const Duration(milliseconds: 300));
    await startAdvertising(uuid); // ✅ UUID 포함 광고 시작
    await startScanning();        // ✅ 상대 UUID 수신
  }


  Future<void> startAdvertising(String uuid) async {
    if (_isAdvertising) return;

    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 777,
      manufacturerData: Uint8List.fromList(utf8.encode(uuid)),
      serviceUuid: '12345678-1234-5678-1234-56789abcdef0',
    );

    await _blePeripheral.start(advertiseData: advertiseData);
    _isAdvertising = true;
    print("📢 광고 시작: 내 UUID는 $uuid");
  }


  Future<void> startScanning({bool force = false}) async {
    if (_isScanning && !force) return;

    await flutter_blue.FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );
    _isScanning = true;

    flutter_blue.FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        for (var data in r.advertisementData.manufacturerData.values) {
          try {
            final remoteUuid = utf8.decode(data);
            print("📡 발견된 기기 UUID: $remoteUuid (${r.device.name}, ${r.device.id})");

            if (!_discoveredDevices.any((d) => d.id == r.device.id)) {
              _discoveredDevices.add(r.device);
              _deviceStreamController.add(_discoveredDevices);
            }
          } catch (e) {
            print("⚠️ UUID 디코딩 실패: $e");
          }
        }
      }
    });
  }

  /// 스캔 중지
  Future<void> stopScanning() async {
    if (_isScanning) {
      await flutter_blue.FlutterBluePlus.stopScan();
      _isScanning = false;
      print("🛑 스캔 중지");
    }
  }

  /// 모든 BLE 작업 정지
  Future<void> stopAll() async {
    if (_isAdvertising) {
      await _blePeripheral.stop();
      _isAdvertising = false;
      print("🛑 광고 정지");
    }

    await stopScanning();
    _notifySubscription?.cancel();
    _notifySubscription = null;
    print("🧹 모든 BLE 작업 정리 완료");
  }

  /// BLE 기기 연결 및 특성 확인
  Future<void> connectToDevice(flutter_blue.BluetoothDevice device) async {
    await device.connect();
    _connectedDevice = device;

    final services = await device.discoverServices();
    for (var service in services) {
      for (var c in service.characteristics) {
        if (c.properties.write && _writeChar == null) {
          _writeChar = c;
        }
        if (c.properties.notify && _notifyChar == null) {
          await c.setNotifyValue(true);
          c.lastValueStream.listen((data) {
            final msg = utf8.decode(data);
            print("📩 수신: $msg");
          });
        }
      }
    }

    if (_writeChar == null) throw Exception("❌ 쓰기 특성 없음");

    _writeCharMap[device.id.id] = _writeChar!;
    if (_notifyChar != null) {
      _notifyCharMap[device.id.id] = _notifyChar!;
    }
  }

  /// 메시지 전송 (기본 대상)
  Future<void> sendMessage(String message) async {
    if (_writeChar == null) {
      print("❌ 전송 실패: 쓰기 특성 없음");
      return;
    }
    await _writeChar!.write(utf8.encode(message), withoutResponse: true);
    print("📤 전송됨: $message");
  }

  /// 메시지 전송 (특정 대상)
  Future<void> sendMessageTo(String targetId, String message) async {
    final char = _writeCharMap[targetId];
    if (char != null) {
      await char.write(utf8.encode(message), withoutResponse: true);
      print("📤 $targetId 에게 전송됨: $message");
    } else {
      print("❌ $targetId 대상 쓰기 특성 없음");
    }
  }

  /// 수신 메시지 구독
  void listenToMessages(void Function(String message) onMessageReceived) {
    _notifySubscription?.cancel();

    if (_notifyChar != null) {
      _notifyChar!.setNotifyValue(true);
      _notifySubscription = _notifyChar!.lastValueStream.listen((data) {
        final msg = utf8.decode(data);
        print("📥 listenToMessages 수신: $msg");
        onMessageReceived(msg);
      });
    } else {
      print("⚠️ notify characteristic 없음");
    }
  }
}
