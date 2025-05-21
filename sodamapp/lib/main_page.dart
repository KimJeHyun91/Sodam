import 'package:flutter/material.dart';
import 'pages/chat_page.dart';
import 'pages/game_page.dart';
import 'pages/my_page_views/my_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final pages = [
    ChatPage(),
    GamePage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '담소'),
          BottomNavigationBarItem(icon: Icon(Icons.games_outlined), label: '놀이'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내 방'),
        ],
      ),
    );
  }
}
