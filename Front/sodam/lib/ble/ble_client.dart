import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../chat/chat_room_page.dart';

Future<void> connectToDevice(BuildContext context, BluetoothDevice device) async {
  try {
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();
    BluetoothCharacteristic? writeChar;
    BluetoothCharacteristic? notifyChar;

    for (var service in services) {
      for (var c in service.characteristics) {
        if (c.properties.write && writeChar == null) writeChar = c;
        if (c.properties.notify && notifyChar == null) notifyChar = c;
      }
    }

    if (writeChar != null && notifyChar != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            roomTitle: device.name.isEmpty ? 'BLE Chat' : device.name,
            writeChars: [writeChar!],     // ✅ null 아님 확정
            notifyChars: [notifyChar!],   // ✅ null 아님 확정
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 Characteristic을 찾을 수 없습니다.")),
      );
    }
  } catch (e) {
    print("Connection error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("연결 실패: $e")),
    );
  }
}
