// import 'package:flutter/material.dart';
// import 'intro_page.dart';
//
// void main() {
//   runApp(MaterialApp(
//     home: const IntroPage(),
//     debugShowCheckedModeBanner: false,
//
//     // 전역 폰트 적용
//     theme: ThemeData(
//       fontFamily: 'EBSHunminjeongeum',
//     ),
//   ));
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'EBSHunminjeongeum',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        fontFamily: 'EBSHunminjeongeum',
        brightness: Brightness.dark,
      ),
      home: const IntroPage(),
    );
  }
}