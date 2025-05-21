import 'package:flutter/material.dart';
import '../main_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      children: [
                        Checkbox(
                          value: autoLogin,
                          onChanged: (val) => setState(() => autoLogin = val ?? false),
                        ),
                        const Text('자동로그인'),
                        const Spacer(),
                        const Text(
                          '접속이름 / 비밀번호 찾기',
                          style: TextStyle(decoration: TextDecoration.underline),
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
                      MaterialPageRoute(builder: (_) => const MainPage()),
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
                  onPressed: () {
                    final id = _idController.text;
                    final pw = _pwController.text;

                    if (id == 'sodam' && pw == '1234') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainPage()),
                      );
                    } else {
                      setState(() {
                        loginError = true;
                      });
                    }
                  },
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
    );
  }
}