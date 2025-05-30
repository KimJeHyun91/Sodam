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

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      var connected = await device.state.first;
      if (connected == BluetoothDeviceState.connected) return;

      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} 연결됨')),
      );

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? notifyChar;

      for (var service in services) {
        for (var c in service.characteristics) {
          if (c.properties.write && writeChar == null) {
            writeChar = c;
          }
          if (c.properties.notify && notifyChar == null) {
            notifyChar = c;
          }
        }
      }

      if (writeChar != null && notifyChar != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              roomTitle: device.name.isEmpty ? 'BLE Chat' : device.name,
              writeChar: writeChar,
              notifyChar: notifyChar,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 Characteristic을 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      debugPrint("BLE 연결 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('연결 실패: $e')),
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
                setState(() => devices.clear());
                _startScanning();
              },
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    title: Text(device.name.isEmpty ? '(No Name)' : device.name),
                    subtitle: Text(device.id.toString()),
                    onTap: () => _connectToDevice(device),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
