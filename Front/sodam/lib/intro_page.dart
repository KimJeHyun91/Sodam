import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login/auth_choice_page.dart';
import 'main_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('loggedInId');
    final token = prefs.getString('token');
    final isGuest = prefs.getBool('isGuest') ?? false;
    final isAutoLogin = prefs.getBool('autoLogin') ?? false;

    print('🪵 로그인 상태 확인');
    print('🧾 id: $id');
    print('🔑 token: $token');
    print('👤 isGuest: $isGuest');
    print('🔁 autoLogin: $isAutoLogin');

    if ((isAutoLogin && id != null && token != null) || isGuest) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthChoicePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/intro.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
