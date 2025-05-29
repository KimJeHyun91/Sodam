import 'package:flutter/material.dart';
import 'pang_game_page.dart'; // SpinPowerGamePage가 정의된 파일

class SpinnerSelectionPage extends StatelessWidget {
  const SpinnerSelectionPage({super.key}); // ✅ const 생성자

  static const List<String> spinnerImages = [
    'assets/game/dragon.png', // 동 - 청룡
    'assets/game/tiger.png',  // 서 - 백호
    'assets/game/bird.png',   // 남 - 주작
    'assets/game/turtle.png', // 북 - 현무
  ];

  static const List<String> spinnerNames = ['청룡', '백호', '주작', '현무'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팽이 선택'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game/spinner_bg.png'), // ✅ 배경 이미지
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '사방신 팽이를 선택하세요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                backgroundColor: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            _buildSpinnerOption(context, 3), // 현무 (북)
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSpinnerOption(context, 1), // 백호 (서)
                _buildSpinnerOption(context, 0), // 청룡 (동)
              ],
            ),
            const SizedBox(height: 20),
            _buildSpinnerOption(context, 2), // 주작 (남)
          ],
        ),
      ),
    );
  }

  Widget _buildSpinnerOption(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _navigateToGame(context, index),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                spinnerImages[index],
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              spinnerNames[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpinPowerGamePage(selectedSpinner: index),
      ),
    );
  }
}
