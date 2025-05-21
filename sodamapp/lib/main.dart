import 'package:flutter/material.dart';
import 'intro_page.dart';

void main() {
  runApp(MaterialApp(
    home: const IntroPage(),
    debugShowCheckedModeBanner: false,

    // 전역 폰트 적용
    theme: ThemeData(
      fontFamily: 'EBSHunminjeongeum',
    ),
  ));
}