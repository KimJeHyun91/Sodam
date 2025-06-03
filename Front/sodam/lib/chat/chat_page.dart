import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../chat/chat_room_model.dart';
import '../components/bottom_nav.dart';
import 'room_create_sheet.dart';
import 'chat_room_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatRoomModel> customRooms = [];
  List<BluetoothDevice> bleUsers = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadBLEUsers();
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

  void _loadBLEUsers() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final isAppUser = r.advertisementData.manufacturerData.values.any(
              (data) => String.fromCharCodes(data).contains("BLE_1to1_CHAT"),
        );
        if (isAppUser && !bleUsers.any((d) => d.id == r.device.id)) {
          setState(() {
            bleUsers.add(r.device);
          });
        }
      }
    });
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

    if (result != null) {
      setState(() {
        customRooms.add(result);
      });
    }
  }

  Future<void> _openChatRoomWithConnection(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      final services = await device.discoverServices();

      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? notifyChar;

      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write && writeChar == null) writeChar = char;
          if (char.properties.notify && notifyChar == null) notifyChar = char;
        }
      }

      if (writeChar != null && notifyChar != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              roomTitle: device.name.isNotEmpty ? device.name : '(이름 없음)',
              writeChars: [writeChar!],
              notifyChars: [notifyChar!],
            ),
          ),
        );
      } else {
        _showError("⚠️ 사용 가능한 BLE 특성을 찾지 못했습니다.");
      }
    } catch (e) {
      _showError("연결 실패: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('이웃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...bleUsers.map((device) {
            final name = device.name.isNotEmpty ? device.name : '(이름 없음)';
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(name),
              subtitle: Text(device.id.toString()),
              onTap: () => _openChatRoomWithConnection(device),
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

// -------------------------- 기타 방 UI -------------------------

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
      )
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
