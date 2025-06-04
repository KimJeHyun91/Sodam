import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../chat/chat_room_model.dart';
import '../components/bottom_nav.dart';
import 'room_create_sheet.dart';
import 'chat_room_page.dart';
import '../services/bluetooth_service.dart' as my_ble;
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatRoomModel> customRooms = [];
  List<BluetoothDevice> bleUsers = [];
  bool isScanning = false;
  bool isAdvertising = false;
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  final my_ble.BluetoothService bt = my_ble.BluetoothService();

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((statuses) {
      if (statuses.values.every((s) => s.isGranted)) {
        _subscribeToScanResults(); // 광고/스캔은 버튼으로 제어
      }
    });

    bt.addListener(_onBluetoothStateChanged);
  }

  void _onBluetoothStateChanged() {
    if (!mounted) return;
    setState(() {
      isScanning = bt.isCurrentlyScanning;
      isAdvertising = bt.isCurrentlyAdvertising;
    });
  }

  @override
  void dispose() {
    bt.removeListener(_onBluetoothStateChanged);
    _scanSubscription.cancel();
    super.dispose();
  }

  void _subscribeToScanResults() {
    _scanSubscription = my_ble.BluetoothService().scanResults.listen((results) {
      if (!mounted) return;
      final devices = results.map((r) => r.device).toList();
      setState(() {
        bleUsers = devices;
      });
    });
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    return await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  void _openRoomCreateSheet() async {
    final result = await showModalBottomSheet<ChatRoomModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RoomCreateSheet(bleUsers: bleUsers),
    );

    if (result != null && mounted) {
      setState(() {
        customRooms.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('이웃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isScanning) const Text("🔍 스캔중"),
                  if (isAdvertising) const Text("📢 광고중"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🔘 광고/스캔 제어 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => bt.startAdvertising(),
                child: const Text("📢 광고 시작"),
              ),
              ElevatedButton(
                onPressed: () => bt.stopAll(),
                child: const Text("🛑 중지"),
              ),
              ElevatedButton(
                onPressed: () => bt.startScanning(duration: const Duration(seconds: 60)),
                child: const Text("🔍 스캔 시작"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...bleUsers.map((device) {
            final name = device.name.isNotEmpty ? device.name : '(이름 없음)';
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(name),
              subtitle: Text(device.id.toString()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(
                      roomTitle: name,
                      targetUserId: device.id.str,
                    ),
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 24),
          const Text('열린마당', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          _openChatList(context),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('비밀마당', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                onPressed: _openRoomCreateSheet,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _secretChatList(context, customRooms),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

Widget _openChatList(BuildContext context) {
  return Column(
    children: [
      _chatRoomItem(context, '소담마당', '카톡이 먹통이네요', color: Colors.green),
      _chatRoomItem(context, '4조', '다들 점심 뭐 먹을래여', color: Colors.yellow, isLocked: true),
    ],
  );
}

Widget _secretChatList(BuildContext context, List<ChatRoomModel> customRooms) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _chatRoomItem(
        context,
        '김철수',
        '둥글게 둥글게 빙글빙글 돌아가며 춤을 춥시다',
      ),
      _chatRoomItem(
        context,
        '4조',
        '다들 점심 뭐 먹을래여',
        color: Colors.yellow,
        isLocked: true,
      ),
      const SizedBox(height: 16),
      if (customRooms.isNotEmpty)
        const Text('내가 만든 방', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ...customRooms.map(
            (room) => _chatRoomItem(
          context,
          room.title,
          '신규방',
          isLocked: room.isSecret,
        ),
      ),
    ],
  );
}

Widget _chatRoomItem(BuildContext context, String name, String message,
    {Color? color, bool isLocked = false, String? image}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color,
      backgroundImage: image != null ? AssetImage(image) : null,
      child: image == null && color == null ? const Icon(Icons.group) : null,
    ),
    title: Text(name),
    subtitle: Text(message),
    trailing: isLocked ? const Icon(Icons.lock_outline) : null,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatRoomPage(roomTitle: name)),
      );
    },
  );
}
