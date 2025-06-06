import 'package:flutter/material.dart';
import 'chat_room_model.dart';
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

  void _openRoomCreateSheet() async {
    final result = await showModalBottomSheet<ChatRoomModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RoomCreateSheet(),
    );

    if (result != null) {
      setState(() {
        customRooms.add(result);
      });
    }
  }

  void _scanForNeighbors() {
    // TODO: 블루투스 스캔 로직 연결
    // ex) FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    print('🔍 주변 이웃 스캔 시작');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('이웃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: _scanForNeighbors, // 아래에 함수 추가 예정
                child: const Text('이웃찾기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _neighborList(context),

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
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

Widget _neighborList(BuildContext context) {
  return Column(
    children: [
      _neighborItem(context, '김제현', 'kjh910920'),
      _neighborItem(context, '이하늘', 'harull817@gmail.com'),
      _neighborItem(context, '정용태', 'grand7246@gmail.com'),
    ],
  );
}

Widget _neighborItem(BuildContext context, String name, String id, {String? image}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: image != null ? AssetImage(image) : null,
      child: image == null ? const Icon(Icons.person) : null,
    ),
    title: Text(name),
    subtitle: Text(id),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(roomTitle: name),
        ),
      );
    },
  );
}

Widget _openChatList(BuildContext context) {
  return Column(
    children: [
      _chatRoomItem(context, '소담마당', '카톡이 먹통이네요', color: Colors.green),
      _chatRoomItem(context, '4조', '다들 점심 뭐 먹을래여', color: Colors.yellow),
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
      ),
      const SizedBox(height: 16),
      if (customRooms.isNotEmpty)
        const Text('내가 만든 방', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ...customRooms.map(
            (room) => _chatRoomItem(
          context,
          room.title,
          '신규방',
        ),
      )
    ],
  );
}

Widget _chatRoomItem(BuildContext context, String name, String message,
    {Color? color, String? image}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color,
      backgroundImage: image != null ? AssetImage(image) : null,
      child: image == null && color == null ? const Icon(Icons.group) : null,
    ),
    title: Text(name),
    subtitle: Text(message),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatRoomPage(roomTitle: name)),
      );
    },
  );
}