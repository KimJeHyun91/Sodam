import 'package:flutter/material.dart';
import '../select_user.dart'; // ✅ SelectUserPage import

class PangIntroPage extends StatelessWidget {
  const PangIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text("팽이치기 게임 소개"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎮 게임 방법",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "1. 화면을 여러 번 탭하여 팽이를 돌리세요.\n"
                  "2. 회전 속도가 높을수록 점수가 높아집니다.\n"
                  "3. 제한 시간 30초 동안 최대한 많이 회전시키세요!\n"
                  "4. 사방신 팽이 중 하나를 선택하고 시작하세요!",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // ✅ 사용자 선택 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectUserPage(gameTitle: '팽이치기'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text("게임 시작",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
