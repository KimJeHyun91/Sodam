import 'package:flutter/material.dart';
import 'package:sodam/style.dart';
import '../../components/bottom_nav.dart';
import '../select_user.dart';

class BiseokIntroPage extends StatelessWidget {
  const BiseokIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('놀이')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/game/biseok.png', // 나중에 이미지 추가
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectUserPage(gameTitle: '비석치기'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
