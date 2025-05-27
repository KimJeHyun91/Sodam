import 'package:flutter/material.dart';
// import '../components/bottom_nav.dart';
import '../game/ddakji_intro.dart';
import '../game/sangaji_intro.dart'; // ✅ 추가
import '../game/namdo_intro.dart';  // ✅ 추가

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('놀이'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gameButton(context, '딱지치기'),
            const SizedBox(height: 12),
            _gameButton(context, '산가지'),
            const SizedBox(height: 12),
            _gameButton(context, '남승도'),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _gameButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () {
        if (title == '딱지치기') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DdakjiIntroPage()),
          );
        } else if (title == '산가지') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SangajiIntroPage()),
          );
        } else if (title == '남승도') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NamdoIntroPage()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
      ),
      child: Text(title, style: const TextStyle(fontSize: 18)),
    );
  }
}
