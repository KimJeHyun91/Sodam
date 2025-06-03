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
      manufacturerData: Uint8List.fromList("BLE_1to1_CHAT".codeUnits),
      serviceUuid: "12345678-1234-5678-1234-56789abcdef0",
    );

    await blePeripheral.start(advertiseData: advertiseData);
    setState(() {
      isAdvertising = true;
    });
  }

  void _startScanning() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        final isAppUser = r.advertisementData.manufacturerData.values.any(
              (data) => String.fromCharCodes(data).contains("BLE_1to1_CHAT"),
        );

        if (isAppUser && !devices.any((d) => d.id == r.device.id)) {
          debugPrint("✅ BLE 사용자 발견: ${r.device.name} (${r.device.id})");
          setState(() {
            devices.add(r.device);
          });
        }
      }
    });
  }

  Future<void> _startChat() async {
    if (selectedDevices.isEmpty) return;

    if (selectedDevices.length == 1) {
      await _connectToSingleDevice(selectedDevices.first);
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
        _showError("사용 가능한 Characteristic을 찾을 수 없습니다.");
      }
    } catch (e) {
      _showError("연결 실패: $e");
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
      _showError("사용 가능한 Characteristic이 없습니다.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
      appBar: AppBar(title: const Text('BLE 사용자 목록')),
      body: Column(
        children: [
          if (isAdvertising)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("📢 광고 중입니다...", style: TextStyle(color: Colors.green)),
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
                child: Text(selectedDevices.length == 1 ? "1:1 채팅 시작" : "단톡방 만들기"),
              ),
            ),
        ],
      ),
    );
  }
}