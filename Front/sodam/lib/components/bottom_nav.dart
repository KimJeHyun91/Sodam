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
        builder: (_) =>
            AlertDialog(
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
        targetPage = ChatPage(key: UniqueKey());
        break;
      case 1:
        targetPage = GamePage(key: UniqueKey());
        break;
      case 2:
        targetPage = MyPage(key: UniqueKey());
        break;
      default:
        return; // 또는 throw Error
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // ✅ 꼭 추가해줘야 스타일 문제 없음
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
      selectedItemColor: isDark ? Colors.white : Colors.black,
      unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '담소',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.games_outlined),
          label: '놀이',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '내 방',
        ),
      ],
    );
  }
}
