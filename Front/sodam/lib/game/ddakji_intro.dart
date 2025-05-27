import 'package:flutter/material.dart';
import 'package:sodam/style.dart';
import '../components/bottom_nav.dart';
import '../chat/chat_page.dart';
import '../myPage/my_page.dart';
import 'select_user.dart'; // ✅ 상대 선택 페이지 import

class DdakjiIntroPage extends StatelessWidget {
  const DdakjiIntroPage({super.key});

  void _onTabTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatPage()),
      );
    } else if (index == 1) {
      // 현재 페이지: 놀이 (아무것도 하지 않음)
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('놀이')),
      body: Stack(
        children: [
          // ✅ 배경 이미지 전체 화면
          Positioned.fill(
            child: Image.asset(
              'assets/ddakji.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ 게임시작 버튼 하단 정렬
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  // ✅ 게임시작 → 상대 선택 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const SelectUserPage(gameTitle: '딱지치기'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('게임시작', style: startButtonTextStyle),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
