import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chat/chat_page.dart';
import '../game/game_page.dart';
import '../myPage/my_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;


    // ❌ 비회원이 게임(1) 또는 내방(2) 클릭 시 차단
    if (isGuest && index == 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('접근 제한'),
          content: const Text('비회원은 이용하실 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

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
