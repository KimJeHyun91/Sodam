// lib/screens/bluetooth_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';
import '../chat/chat_room_page.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final BluetoothService ble = BluetoothService();
  List<flutter_blue.BluetoothDevice> devices = [];
  Set<flutter_blue.BluetoothDevice> selectedDevices = {};

  @override
  void initState() {
    super.initState();
    _initBLE();
  }

  Future<void> _initBLE() async {
    await _requestPermissions();
    await ble.initBluetooth();

    ble.discoveredDevices.listen((newDevices) {
      setState(() {
        devices = newDevices;
      });
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  void _startChat() async {
    if (selectedDevices.length != 1) {
      _showError("현재는 1:1 채팅만 지원합니다.");
      return;
    }

    try {
      final device = selectedDevices.first;
      await ble.connectToDevice(device);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            roomTitle: device.name,
            writeChars: [ble.writeChar!],
            notifyChars: [ble.notifyChar!],
          ),
        ),
      );
    } catch (e) {
      _showError("연결 실패: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    ble.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE 사용자 목록")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, index) {
                final device = devices[index];
                final selected = selectedDevices.contains(device);
                return ListTile(
                  title: Text(device.name.isEmpty ? '(이름 없음)' : device.name),
                  subtitle: Text(device.id.toString()),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedDevices.add(device);
                        } else {
                          selectedDevices.remove(device);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (selectedDevices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _startChat,
                child: const Text("채팅 시작"),
              ),
            ),
        ],
      ),
    );
  }
}
