import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'dart:typed_data';

class BleServer {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  Future<void> startAdvertising() async {
    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 1234,
      manufacturerData: Uint8List.fromList("BLE_1to1_CHAT".codeUnits),
      serviceUuid: "12345678-1234-5678-1234-56789abcdef0",
    );
    await _peripheral.start(advertiseData: advertiseData);
  }

  void stopAdvertising() {
    _peripheral.stop();
  }
}