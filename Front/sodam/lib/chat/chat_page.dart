import 'package:flutter/material.dart';
// import '../components/bottom_nav.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('담소'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(child: Text('담소 페이지')),
      // bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0), // ✅ 담소 탭
    );
  }
}
