import 'package:flutter/material.dart';

class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({super.key});

  @override
  State<ThemeSettingPage> createState() => _ThemeSettingPageState();
}

class _ThemeSettingPageState extends State<ThemeSettingPage> {
  bool isDarkMode = false;
  int selectedTheme = 0; // 0: pink, 1: blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("화면"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 다크모드 토글
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("다크모드", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: isDarkMode,
                    onChanged: (val) {
                      setState(() {
                        isDarkMode = val;
                      });
                    },
                  )
                ],
              ),
            ),

            const Text("내 배경", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 배경 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _themePreview(0, Colors.pink[100]!),
                _themePreview(1, Colors.blue[200]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 테마 미리보기 위젯
  Widget _themePreview(int index, Color color) {
    final isSelected = selectedTheme == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = index;
        });
      },
      child: Container(
        width: 120,
        height: 180,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: const [
              Positioned(
                top: 8,
                left: 8,
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: SizedBox(
                  width: 60,
                  height: 24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}