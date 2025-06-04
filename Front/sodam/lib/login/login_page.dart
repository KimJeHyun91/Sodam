import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodam/main_page.dart';
import 'find_id_page.dart';
import 'reset_password_page.dart';
import 'guest_warning_page.dart';
import 'package:sodam/dio_client.dart';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../api/point_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool autoLogin = false;
  bool loginError = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idController.text;
    final pw = _pwController.text;

    try {
      final response = await DioClient.dio.post(
        '/member/login',
        data: {
          'id': id,
          'password': pw,
        },
      );

      print('로그인 응답: ${response.data}');

      final data = response.data;

      if (response.data['message_no'] == 1020) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']);
        await prefs.setString('loggedInId', id);

        final pointNo = await fetchPointNo(id);
        if (pointNo != null) {
          await prefs.setInt('point_no', pointNo);
          print('✅ 엽전 번호 저장 완료: $pointNo');
        }

        await prefs.remove('isGuest');
        await prefs.remove('guest_uuid');
        await prefs.remove('guest_nickname');
        await prefs.setString('jwtToken', response.data['token']);
        print('✅ 저장된 JWT 토큰: ${prefs.getString('jwtToken')}');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false, // 이전 스택 다 제거

        );
      } else {
        setState(() {
          loginError = true;
        });
      }
    } catch (e) {
      setState(() {
        loginError = true;
      });
    }
  }

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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // 접속이름
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('접속이름', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextField(controller: _idController),
                    const SizedBox(height: 16),

                    // 비밀번호
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('비밀번호', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextField(
                      controller: _pwController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    // 에러 메시지
                    if (loginError)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '접속이름 또는 비밀번호가 잘못 되었습니다.\n아이디와 비밀번호를 확인해주세요.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 자동로그인 체크박스
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FindIdPage()),
                            );
                          },
                          child: const Text(
                            '접속이름',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Text(' / '),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                            );
                          },
                          child: const Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 비회원 접속 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GuestWarningPage()),
                    );
                  },
                  child: const Text('비회원 접속'),
                ),
              ),

              const SizedBox(height: 10),

              // 접속 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9DAB2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _login,
                  child: const Text(
                    '접속',
                    style: TextStyle(color: Colors.black),
                  ),
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