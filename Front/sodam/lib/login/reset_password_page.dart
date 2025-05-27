import 'package:flutter/material.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('손글주소'),
                  const TextField(),
                  const SizedBox(height: 8),
                  const Text(
                    '등록되지 않은 이메일 입니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const Text(
                    '인증번호를 다시 확인해주세요.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9DAB2),
                      ),
                      child: const Text('인증번호 받기'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('비밀번호 재설정'),
                  const TextField(),
                  const SizedBox(height: 16),
                  const Text('비밀번호 확인'),
                  const TextField(),
                  const Text(
                    '비밀번호가 일치하지 않습니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9DAB2),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('확인'),
            ),

          ],
        ),
      ),
    );
  }
}
