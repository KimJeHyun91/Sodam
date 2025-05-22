import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'theme_setting_page.dart';
import 'notification_setting_page.dart';
import 'help_page.dart';
import 'package:sodam_test/intro_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("손보기"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _settingItem("회원정보수정", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            }),
            _settingItem("화면", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeSettingPage()),
              );
            }),
            _settingItem("알림", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingPage()),
              );
            }),
            _settingItem("도움방", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            }),
            const Spacer(),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 로그아웃 처리 (필요하다면 토큰 삭제 등 추가)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IntroPage()),
          // ← 처음 화면으로 이동
              (route) => false, // 스택 전부 제거
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          "로그아웃",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}