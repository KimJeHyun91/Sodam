import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원정보수정"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 24),

              // 별칭 입력
              _labelText("별칭"),
              _textField(initialText: "짱구봉구"),

              const SizedBox(height: 16),

              // 비밀번호
              _labelText("비밀번호"),
              _textField(obscure: true),

              const SizedBox(height: 16),

              // 비밀번호 확인
              _labelText("비밀번호 확인"),
              _textField(obscure: true),

              const SizedBox(height: 24),

              // 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // 저장 처리
                    },
                    child: const Text("수정"),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      // 탈퇴 처리
                    },
                    child: const Text("회원탈퇴"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelText(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _textField({String? initialText, bool obscure = false}) {
    return TextFormField(
      initialValue: initialText,
      obscureText: obscure,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}