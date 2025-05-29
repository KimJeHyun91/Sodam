import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login_page.dart';
import '../dio_client.dart';
import 'dart:async';

class FindIdPage extends StatefulWidget {
  const FindIdPage({super.key});

  @override
  State<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  String? _idResult;
  String? _emailError;
  String? _codeError;
  bool _verified = false;

  Timer? _emailTimer;
  int _timeLeft = 180;

  void _startEmailTimer() {
    _emailTimer?.cancel();
    setState(() {
      _timeLeft = 180;
    });
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() {
          _codeError = '인증 시간이 초과되었습니다.';
        });
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  String _formatTimeLeft() {
    final minutes = _timeLeft ~/ 60;
    final seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimerText() {
    if (_verified || _timeLeft <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '남은 시간: ${_formatTimeLeft()}',
          style: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = '이메일을 입력해주세요.';
        _verified = false;
        _idResult = null;
      });
      return;
    }

    try {
      await DioClient.dio.post('/auth/send-code-find-id', data: {'email': email});
      setState(() {
        _emailError = null;
        _codeError = null;
        _verified = false;
        _idResult = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 전송되었습니다.')),
      );
      _startEmailTimer();
    } catch (e) {
      setState(() {
        _emailError = '등록되지 않은 이메일 입니다.';
        _verified = false;
        _idResult = null;
      });
    }
  }

  Future<void> _verifyAndFindId() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      setState(() {
        _codeError = '모든 필드를 입력해주세요.';
        _verified = false;
        _idResult = null;
      });
      return;
    }

    try {
      final verifyRes = await DioClient.dio.post(
        '/auth/verify-code',
        data: {'email': email, 'code': code},
      );

      if (verifyRes.data['status'] == 'success') {
        final idRes = await DioClient.dio.get(
          '/member/find-id',
          queryParameters: {'email': email},
        );
        setState(() {
          _verified = true;
          _idResult = idRes.data['id'] ?? '정보 없음';
          _codeError = null;
        });
      } else {
        setState(() {
          _codeError = '인증번호가 일치하지 않습니다.';
          _verified = false;
          _idResult = null;
        });
      }
    } on DioError catch (e) {
      String message = '서버 오류';
      if (e.response?.data is Map<String, dynamic>) {
        final res = e.response?.data as Map<String, dynamic>;
        message = res['message'] ?? message;
      }
      setState(() {
        _codeError = message.contains('인증번호') ? '인증번호가 일치하지 않습니다.' : message;
        _verified = false;
        _idResult = null;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _emailTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('접속이름 찾기')),
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
                  TextField(controller: _emailController),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(_emailError!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 8),

                  const Text('인증번호'),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _codeController)),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendVerificationCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9DAB2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: const Text('인증번호 받기'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _verifyAndFindId,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCE5FF),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                  _buildTimerText(),
                  if (_codeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(_codeError!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 20),

                  if (_verified && _idResult != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('가입된 접속이름'),
                          Text(_idResult!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
              child: const Text('로그인 화면으로'),
            ),
          ],
        ),
      ),
    );
  }
}
