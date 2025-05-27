import 'package:flutter/material.dart';

// 사용할 메인 폰트 이름 (pubspec.yaml의 family와 일치해야 함)
const String mainFont = 'EBSHunminjeongeum';

// ✅ 공통 텍스트 스타일 예시
const TextStyle gameButtonTextStyle = TextStyle(
  fontFamily: mainFont,
  fontSize: 18,
  color: Colors.black,
);
const TextStyle ddakjiTitleStyle = TextStyle(
  fontSize: 24,
  fontFamily: 'EBS', // pubspec.yaml의 family명과 일치해야 함
);

const TextStyle startButtonTextStyle = TextStyle(
  fontSize: 18,
  fontFamily: 'EBS',
  color: Colors.black,
);
const TextStyle introTitleStyle = TextStyle(
  fontFamily: mainFont,
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle introSubtitleStyle = TextStyle(
  fontFamily: mainFont,
  fontSize: 16,
  color: Colors.grey,
);

// ✅ 앱 전역 테마 (선택적으로 main.dart에서 사용 가능)
final ThemeData appTheme = ThemeData(
  fontFamily: mainFont,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
);
