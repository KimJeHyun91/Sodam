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
import 'main_page.dart';
import 'login/auth_choice_page.dart';

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
  Widget _initialScreen = const CircularProgressIndicator(); // 초기 상태: 로딩

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _checkLoginStatus(); // ✅ 로그인 여부 확인
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('loggedInId');
    final token = prefs.getString('token');
    final isGuest = prefs.getBool('isGuest') ?? false;

    setState(() {
      if (id != null && token != null) {
        _initialScreen = const MainPage(); // 회원 로그인
      } else if (isGuest) {
        _initialScreen = const MainPage(); // 비회원 로그인
      } else {
        _initialScreen = const AuthChoicePage(); // 비로그인 상태
      }
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
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF7F7F7),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),

      darkTheme: ThemeData(
        fontFamily: 'EBSHunminjeongeum',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),

      home: _initialScreen,
    );
  }
}