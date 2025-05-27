import 'package:flutter/material.dart';
import '../chat/chat_page.dart';
import '../game/game_page.dart';
import '../myPage/my_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    Widget targetPage;

    switch (index) {
      case 0:
        targetPage = const ChatPage();
        break;
      case 1:
        targetPage = const GamePage();
        break;
      case 2:
        targetPage = const MyPage();
        break;
      default:
        return;
    }

    // 중복 클릭 방지
    if (index != currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '담소'),
        BottomNavigationBarItem(icon: Icon(Icons.games_outlined), label: '놀이'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내 방'),
      ],
    );
  }
}
