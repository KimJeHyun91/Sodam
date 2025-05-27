import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
    );
  }
}