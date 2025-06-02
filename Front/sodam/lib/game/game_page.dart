import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'ttagji/ttagji_intro.dart';
import 'Namseungdo/namdo_intro.dart';
import 'biseok/biseok_intro.dart';
import 'paeng-i/pang_intro.dart'; // ✅ 팽이치기 intro 페이지 import
import 'rockpaperscissors/rock_paper_intro.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('놀이')
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gameButton(context, '딱지치기'),
            const SizedBox(height: 12),
            _gameButton(context, '남승도'),
            const SizedBox(height: 12),
            _gameButton(context, '비석치기'),
            const SizedBox(height: 12),
            _gameButton(context, '팽이치기'), // ✅ 팽이치기만 유지
            const SizedBox(height: 12),
            _gameButton(context, '가위바위보'), // ✅ 팽이치기만 유지
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _gameButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () {
        if (title == '딱지치기') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TtagjiIntroPage()),
          );
        } else if (title == '남승도') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NamdoIntroPage()),
          );
        } else if (title == '비석치기') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BiseokIntroPage()),
          );
        } else if (title == '팽이치기') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PangIntroPage()),
          );
        } else if (title == '가위바위보') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RockPaperIntroPage()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF7F7F7),
          foregroundColor: Color(0xFF1E1E1E),
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
