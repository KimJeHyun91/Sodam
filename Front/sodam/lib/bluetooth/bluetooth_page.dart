import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import '../chat/chat_room_page.dart';

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
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startBluetoothFlow();
  }

  Future<void> _startBluetoothFlow() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _startChat() async {
    if (selectedDevices.isEmpty) {
      await _startAsPriority();
      _showError("방장이 되었습니다. 다른 기기가 연결하길 기다립니다.");
    } else {
      await _startAsSecondary();
      if (selectedDevices.length == 1) {
        await _connectToSingleDevice(selectedDevices.first);
      } else {
        await _connectToGroupDevices();
      }
    }
  }

  Future<void> _startAsPriority() async {
    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 1234,
      manufacturerData: Uint8List.fromList([0x50, 0x52, 0x49, 0x4F]),
      serviceUuid: "12345678-1234-5678-1234-56789abcdef0",
    );

    await blePeripheral.start(advertiseData: advertiseData);
    setState(() {
      isAdvertising = true;
    });
  }

  Future<void> _startAsSecondary() async {
    FlutterBluePlus.startScan(
      withServices: [Guid("12345678-1234-5678-1234-56789abcdef0")],
      timeout: const Duration(seconds: 12),
    );

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devices.any((d) => d.id == r.device.id)) {
          setState(() {
            devices.add(r.device);
          });
        }
      }
    });

    await Future.delayed(const Duration(seconds: 12));
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
  }

  Future<void> _connectToSingleDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      final services = await device.discoverServices();
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
        final services = await device.discoverServices();
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    blePeripheral.stop();
    _scanSubscription?.cancel();
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
              child: Text("방장: 광고 중입니다", style: TextStyle(color: Colors.green)),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  devices.clear();
                  selectedDevices.clear();
                });
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
          if (selectedDevices.isNotEmpty || !isAdvertising)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _startChat,
                child: Text(
                  selectedDevices.isEmpty ? "단톡방 만들기" : selectedDevices.length == 1 ? "1:1 채팅 시작" : "단톡방 참가",
                ),
              ),
            ),
        ],
      ),
    );
  }
}
