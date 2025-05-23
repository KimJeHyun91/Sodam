import 'package:flutter/material.dart';
import '../main_page.dart';
import 'package:dio/dio.dart';

final dio = Dio();

void configureDio() {
  // 기본 옵션 설정
  dio.options.baseUrl = 'http://10.0.2.2:8080'; // 기본 URL
  dio.options.connectTimeout = Duration(seconds: 5); // 연결 타임아웃: 5초
  dio.options.receiveTimeout = Duration(seconds: 3); // 응답 수신 타임아웃: 3초
  dio.options.headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer YOUR_ACCESS_TOKEN', // 예시: 기본 인증 헤더
  };
}

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
  void initState() {
    super.initState();
    configureDio(); // 여기에 추가
  }

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
                    onPressed: () async {
                      final id = _idController.text;
                      final pw = _pwController.text;

                      final success = await tryLogin(id, pw);
                      if (success) {
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
  Future<bool> tryLogin(String id, String password) async {
    try {
      final res = await dio.get(
        '/member/login',
        queryParameters: {
          'id': id,
          'password': password,
        },
      );

      print('로그인 응답값: ${res.data}'); // 디버깅용

      // 백엔드에서 1020이면 로그인 성공
      if (res.data == 1020) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('로그인 오류: $e');
      return false;
    }
  }
}
