import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_room_page.dart';

class BleChatPage extends StatefulWidget {
  const BleChatPage({super.key});

  @override
  State<BleChatPage> createState() => _BleChatPageState();
}

class _BleChatPageState extends State<BleChatPage> {
  List<BluetoothDevice> devices = [];
  Set<BluetoothDevice> selectedDevices = {};

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse
    ].request();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (!devices.any((d) => d.id == r.device.id)) {
          setState(() => devices.add(r.device));
        }
      }
    });
  }

  void _startChat() {
    if (selectedDevices.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          roomTitle: selectedDevices.length == 1
              ? selectedDevices.first.name
              : '단톡방 (${selectedDevices.length}명)',
          writeChar: null,
          notifyChar: null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE 이웃 선택')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final selected = selectedDevices.contains(device);
                return ListTile(
                  title: Text(device.name.isEmpty ? '(이름 없음)' : device.name),
                  subtitle: Text(device.id.toString()),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (bool? val) {
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _startChat,
              child: const Text('채팅 시작'),
            ),
          ),
        ],
      ),
    );
  }
}
