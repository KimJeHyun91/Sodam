import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'theme_setting_page.dart';
import 'notification_setting_page.dart';
import 'help_page.dart';
import '../intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getString('loggedInId') == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("손보기"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _settingItem(
              context,
              "회원정보수정",
              enabled: !isGuest,
              onTap: isGuest
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
            _settingItem(context, "화면", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSettingPage()));
            }),
            _settingItem(context, "알림", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingPage()));
            }),
            _settingItem(context, "도움방", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
            }),
            const Spacer(),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(BuildContext context, String title, {VoidCallback? onTap, bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? Colors.grey[850] : Colors.white)
              : Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? Theme.of(context).textTheme.bodyMedium?.color : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("로그아웃"),
            content: const Text("정말 로그아웃하시겠습니까?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("로그아웃")),
            ],
          ),
        );

        if (shouldLogout == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('loggedInId');

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const IntroPage()),
                  (route) => false,
            );
          }
        }
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
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}