import 'package:flutter/material.dart';
import 'main_page.dart'; // 👉 네가 이동할 메인페이지

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();

    // 3초 후 자동으로 메인페이지로 이동
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/intro.png', // 👉 너가 넣은 사진 경로
        fit: BoxFit.cover,  // 화면에 꽉 차게
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
