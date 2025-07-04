import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/chat_page.dart';
import 'game/game_page.dart';
import 'mypage/my_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final pages = [
    const ChatPage(),
    const GamePage(),
    const MyPage(),
  ];

  @override
  void initState() {
    super.initState();
    debugGuestInfo(); // 비회원 정보 출력
  }

  void debugGuestInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final guestId = prefs.getString('guest_uuid');
    final nickname = prefs.getString('guest_nickname');
    final isGuest = prefs.getBool('isGuest') ?? false;

    print('🧩 UUID: $guestId');
    print('🧩 닉네임: $nickname');
    print('🧩 isGuest: $isGuest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
    );
  }
}