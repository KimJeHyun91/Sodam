import 'package:flutter/material.dart';
import 'package:sodam/main_page.dart';
import 'signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

Future<void> initializeGuestAccount() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('guest_uuid')) {
    final uuid = DateTime.now().microsecondsSinceEpoch.toString();
    prefs.setString('guest_uuid', uuid);
  }

  if (!prefs.containsKey('guest_nickname')) {
    final List<String> used = prefs.getStringList('used_guest_numbers') ?? [];

    int rangeStart = 1;
    int rangeSize = 100;

    int guestNumber;
    while (true) {
      final currentRange =
        List.generate(rangeSize, (i) => (rangeStart + i).toString());

      final available = currentRange.toSet().difference(used.toSet()).toList();

      if (available.isNotEmpty) {
        guestNumber = int.parse(available[Random().nextInt(available.length)]);
        break;
      } else {
        rangeStart += rangeSize;
      }
    }
    prefs.setString('guest_nickname', '비회원$guestNumber');
    used.add(guestNumber.toString());
    prefs.setStringList('used_guest_numbers', used);
  }
  // 비회원 표시
  prefs.setBool('isGuest', true);
}

class GuestWarningPage extends StatelessWidget {
  const GuestWarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.light().copyWith(brightness: Brightness.light),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 경고 박스
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '주의 !',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '비회원은\n열린마당 이용만 가능합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 비회원 접속 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await initializeGuestAccount();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    );
                  },
                  child: const Text('비회원 접속'),
                ),
              ),

              const SizedBox(height: 10),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9DAB2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text('회원가입', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
