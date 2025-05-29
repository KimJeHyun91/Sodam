import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login_page.dart';
import '../dio_client.dart';
import 'dart:async';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();

  String? _emailError;
  String? _codeError;
  String? _pwError;
  String? _pwConfirmMessage;
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
      });
      return;
    }

    try {
      final response = await DioClient.dio.post('/auth/send-code-reset-pw', data: {'email': email});
      if (response.data['status'] == 'success') {
        setState(() {
          _emailError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증번호가 전송되었습니다.')),
        );
        _startEmailTimer(); // 타이머 시작
      } else {
        setState(() {
          _emailError = response.data['message'];
        });
      }
    } catch (e) {
      String message = '인증번호 요청 실패';
      if (e is DioError && e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      setState(() {
        _emailError = message;
      });
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      setState(() {
        _codeError = '모든 필드를 입력해주세요.';
      });
      return;
    }

    try {
      final response = await DioClient.dio.post(
        '/auth/verify-code',
        data: {'email': email, 'code': code},
      );

      if (response.data['status'] == 'success') {
        setState(() {
          _verified = true;
          _codeError = null;
        });
      } else {
        setState(() {
          _codeError = '인증번호가 일치하지 않습니다.';
        });
      }
    } catch (_) {
      setState(() {
        _codeError = '인증번호가 일치하지 않습니다.';
      });
    }
  }

  void _checkPasswords() {
    final newPassword = _pwController.text.trim();
    final confirmPassword = _pwConfirmController.text.trim();

    setState(() {
      _pwError = null;

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _pwConfirmMessage = null;
        return;
      }

      if (newPassword == confirmPassword) {
        _pwConfirmMessage = '비밀번호 일치';
      } else {
        _pwConfirmMessage = '비밀번호 불일치';
      }
    });
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _pwController.text.trim();
    final confirm = _pwConfirmController.text.trim();

    if (newPassword != confirm) {
      setState(() {
        _pwConfirmMessage = '비밀번호 불일치';
      });
      return;
    }

    try {
      final response = await DioClient.dio.post('/auth/reset-password', data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });

      dynamic data = response.data;
      int resultCode;

      if (data is int) {
        resultCode = data;
      } else if (data is String) {
        resultCode = int.tryParse(data) ?? -1;
      } else if (data is Map && data.containsKey('code')) {
        resultCode = data['code'];
      } else {
        resultCode = -1;
      }

      if (resultCode == 1050) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
        );
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else if (resultCode == 1052) {
        setState(() {
          _pwError = '기존에 사용했던 비밀번호입니다.';
        });
      } else if (resultCode == 1051) {
        setState(() {
          _codeError = '인증번호가 일치하지 않습니다.';
        });
      } else {
        setState(() {
          _pwError = '비밀번호 변경 실패 (코드: $resultCode)';
        });
      }
    } catch (e) {
      setState(() {
        _pwError = '서버 오류';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _emailTimer?.cancel();
    super.dispose();
  }

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
                  TextField(
                    controller: _emailController,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  if (_emailError != null)
                    Text(_emailError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),

                  const Text('인증번호'),
                  TextField(controller: _codeController),
                  _buildTimerText(), // 👈 타이머 UI 위치
                  if (_codeError != null)
                    Text(_codeError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _sendVerificationCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9DAB2),
                        ),
                        child: const Text('인증번호 받기'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCE5FF),
                        ),
                        child: const Text('확인'),
                      ),
                    ],
                  ),

                  if (_verified) ...[
                    const SizedBox(height: 20),
                    const Text('비밀번호 재설정'),
                    TextField(
                      controller: _pwController,
                      obscureText: true,
                      onChanged: (_) => _checkPasswords(),
                    ),
                    if (_pwError != null)
                      Text(_pwError!, style: const TextStyle(color: Colors.red)),

                    const SizedBox(height: 16),
                    const Text('비밀번호 확인'),
                    TextField(
                      controller: _pwConfirmController,
                      obscureText: true,
                      onChanged: (_) => _checkPasswords(),
                    ),
                    if (_pwConfirmMessage != null)
                      Text(
                        _pwConfirmMessage!,
                        style: TextStyle(
                          color: _pwConfirmMessage == '비밀번호 일치'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9DAB2),
                      ),
                      child: const Text('비밀번호 변경'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
