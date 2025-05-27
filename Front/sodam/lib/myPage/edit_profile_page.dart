// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Dio dio = Dio();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = true;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserNickname();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('사진 앨범에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.folder),
              //   title: const Text('파일에서 선택'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     final result = await FilePicker.platform.pickFiles(type: FileType.image);
              //     if (result != null && result.files.single.path != null) {
              //       final file = File(result.files.single.path!);
              //       setState(() {
              //         _selectedImage = file;
              //       });
              //     }
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('취소'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> loadUserNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');

      if (id == null) {
        nicknameController.text = '비회원';
        setState(() => isLoading = false);
        return;
      }

      final response = await dio.get(
        'http://10.0.2.2:8080/member/get_member_object',
        queryParameters: {'id': id},
      );

      if (response.data is Map<String, dynamic>) {
        nicknameController.text = response.data['nickname'] ?? '';
      } else {
        nicknameController.text = '정보 없음';
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("닉네임 로딩 실패: $e");
      nicknameController.text = '에러';
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원정보수정"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const CircleAvatar(
              //   radius: 100,
              //   backgroundImage: AssetImage('assets/images/gibon2.jpeg'),
              // ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const AssetImage('assets/images/gibon2.jpeg') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 24),
                        onPressed: _showPhotoOptions, // ✅ Bottom sheet 띄우기
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 별칭 입력
              _labelText("별칭"),
              _textField(controller: nicknameController),

              const SizedBox(height: 16),

              // 비밀번호
              _labelText("비밀번호"),
              _textField(controller: passwordController, obscure: true),

              const SizedBox(height: 16),

              // 비밀번호 확인
              _labelText("비밀번호 확인"),
              _textField(controller: confirmPasswordController, obscure: true),

              const SizedBox(height: 24),

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
            onPressed: () async {
              final nickname = nicknameController.text.trim();
              final password = passwordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (password != confirmPassword) {
                // 비밀번호 불일치
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("오류"),
                    content: const Text("비밀번호 확인이 일치하지 않습니다"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              final id = prefs.getString('loggedInId');

              if (id == null) return;

              try {
                final response = await dio.put(
                  'http://10.0.2.2:8080/member/update',
                  data: {
                    "id": id,
                    "nickname": nickname,
                    "password": password,
                  },
                );

                if (response.data == 1030) {
                  // 성공
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("성공"),
                        content: const Text("회원 정보가 수정되었습니다"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("확인"),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  // 실패
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("수정에 실패했습니다")),
                  );
                }
              } catch (e) {
                print("수정 실패: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("서버 요청 중 오류 발생")),
                );
              }
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
                      // 탈퇴 처리 예정
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

  Widget _textField({required TextEditingController controller, bool obscure = false}) {
    return TextFormField(
      controller: controller,
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