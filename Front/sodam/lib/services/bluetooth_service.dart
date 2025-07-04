// lib/services/bluetooth_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;

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

  final _discoveredDevices = <flutter_blue.BluetoothDevice>[];
  final _deviceStreamController =
  StreamController<List<flutter_blue.BluetoothDevice>>.broadcast();

  Stream<List<flutter_blue.BluetoothDevice>> get discoveredDevices =>
      _deviceStreamController.stream;

  flutter_blue.BluetoothCharacteristic? get writeChar => _writeChar;
  flutter_blue.BluetoothCharacteristic? get notifyChar => _notifyChar;

  Future<void> initBluetooth() async {
    await stopAll();
    await Future.delayed(const Duration(milliseconds: 300));
    await startAdvertising();
    await startScanning();
  }

  Future<void> startAdvertising() async {
    if (_isAdvertising) return;

    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 777,
      manufacturerData: Uint8List.fromList(utf8.encode("BLE_1to1_CHAT")),
      serviceUuid: '12345678-1234-5678-1234-56789abcdef0',
    );

    await _blePeripheral.start(advertiseData: advertiseData);
    _isAdvertising = true;
    print("📢 광고 시작");
  }

  Future<void> startScanning() async {
    if (_isScanning) return;

    await flutter_blue.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    _isScanning = true;
    flutter_blue.FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final isAppUser = r.advertisementData.manufacturerData.values.any(
              (data) => utf8.decode(data).contains("BLE_1to1_CHAT"),
        );

        if (isAppUser &&
            !_discoveredDevices.any((d) => d.id == r.device.id)) {
          _discoveredDevices.add(r.device);
          _deviceStreamController.add(_discoveredDevices);
        }
      }
    });
  }

  Future<void> connectToDevice(flutter_blue.BluetoothDevice device) async {
    await device.connect();
    _connectedDevice = device;

    final services = await device.discoverServices();
    for (var service in services) {
      for (var c in service.characteristics) {
        if (c.properties.write && _writeChar == null) _writeChar = c;
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
  }

  Future<void> sendMessage(String message) async {
    if (_writeChar == null) {
      print("❌ 전송 실패: 쓰기 특성 없음");
      return;
    }
    await _writeChar!.write(utf8.encode(message), withoutResponse: true);
    print("📤 전송됨: $message");
  }

  Future<void> stopAll() async {
    if (_isAdvertising) {
      await _blePeripheral.stop();
      _isAdvertising = false;
    }
    if (_isScanning) {
      await flutter_blue.FlutterBluePlus.stopScan();
      _isScanning = false;
    }
  }
}
