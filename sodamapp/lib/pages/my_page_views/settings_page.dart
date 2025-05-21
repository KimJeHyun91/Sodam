import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'theme_setting_page.dart';
import 'notification_setting_page.dart';
import 'help_page.dart';

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
}