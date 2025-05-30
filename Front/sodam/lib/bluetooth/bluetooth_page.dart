import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import '../chat/chat_room_page.dart';
import 'dart:typed_data';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  List<BluetoothDevice> devices = [];
  Set<BluetoothDevice> selectedDevices = {};
  bool isAdvertising = false;

  @override
  void initState() {
    super.initState();
    _startBluetoothFlow();
  }

  Future<void> _startBluetoothFlow() async {
    await _requestPermissions();
    _startAdvertising();
    _startScanning();
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

  void _startAdvertising() async {
    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 1234,
      manufacturerData: Uint8List.fromList([0x01, 0x02, 0x03, 0x04]),
      serviceUuid: "12345678-1234-5678-1234-56789abcdef0",
    );

    await blePeripheral.start(advertiseData: advertiseData);
    setState(() {
      isAdvertising = true;
    });
  }

  void _startScanning() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devices.any((d) => d.id == r.device.id)) {
          setState(() {
            devices.add(r.device);
          });
        }
      }
    });
  }

  Future<void> _startChat() async {
    if (selectedDevices.isEmpty) return;

    // 1명 선택 시: 1:1
    if (selectedDevices.length == 1) {
      BluetoothDevice device = selectedDevices.first;
      await _connectToSingleDevice(device);
    } else {
      await _connectToGroupDevices();
    }
  }

  Future<void> _connectToSingleDevice(BluetoothDevice device) async {
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
              writeChars: [writeChar!],
              notifyChars: [notifyChar!],
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 Characteristic을 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      debugPrint("1:1 연결 실패: $e");
    }
  }

  Future<void> _connectToGroupDevices() async {
    List<BluetoothCharacteristic> writeChars = [];
    List<BluetoothCharacteristic> notifyChars = [];

    for (var device in selectedDevices) {
      try {
        await device.connect();
        var services = await device.discoverServices();
        for (var service in services) {
          for (var c in service.characteristics) {
            if (c.properties.write) writeChars.add(c);
            if (c.properties.notify) notifyChars.add(c);
          }
        }
      } catch (e) {
        debugPrint("단톡 연결 실패: $e");
      }
    }

    if (writeChars.isNotEmpty && notifyChars.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            roomTitle: "단체 채팅방",
            writeChars: writeChars,
            notifyChars: notifyChars,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 Characteristic이 없습니다.")),
      );
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    blePeripheral.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth 사용자 목록')),
      body: Column(
        children: [
          if (isAdvertising)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("광고 중입니다...", style: TextStyle(color: Colors.green)),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  devices.clear();
                  selectedDevices.clear();
                });
                _startScanning();
              },
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final selected = selectedDevices.contains(device);
                  return ListTile(
                    title: Text(device.name.isEmpty ? '(No Name)' : device.name),
                    subtitle: Text(device.id.toString()),
                    trailing: Checkbox(
                      value: selected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
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
          ),
          if (selectedDevices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _startChat,
                child: Text(
                  selectedDevices.length == 1 ? "1:1 채팅 시작" : "단톡방 만들기",
                ),
              ),
            ),
        ],
      ),
    );
  }
}
