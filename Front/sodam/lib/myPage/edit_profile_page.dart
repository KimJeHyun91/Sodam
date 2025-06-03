import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  bool isLoading = true;
  bool isFormValid = false;
  String? nicknameError;
  String? passwordError;
  String? confirmPasswordError;
  String? birthdayError;
  String? nameError;
  String? emailError;

  String? originalNickname;
  String? originalPassword;
  String? originalEmail;
  String? originalName;
  String? originalBirthday;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserInfo();

    nicknameController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    nameController.addListener(_validateForm);
    birthdayController.addListener(_validateForm);

  }

  void _validateForm() {
    final nickname = nicknameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final birthday = birthdayController.text.trim();

    // 별칭 유효성 (한글 2~8자 + 숫자 0~4자리)
    final nickValid = RegExp(r'^(?:[가-힣]{2,8}\d{0,4}|\d{1,4})$').hasMatch(nickname);
    nicknameError = nickValid || nickname == originalNickname ? null : '별칭 형식이 올바르지 않습니다.';

    // 비밀번호 유효성
    final pwValid = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_]).{8,16}$').hasMatch(password);
    final pwSimilarToId = false; // ID 없음
    passwordError = password.isEmpty
        ? null
        : !pwValid ? '비밀번호 형식이 잘못되었습니다.'
        : pwSimilarToId ? '아이디와 비슷한 문자열이 포함됨'
        : null;

    confirmPasswordError = password != confirmPassword ? '비밀번호가 일치하지 않습니다.' : null;

    // 이메일 간단 유효성 (추가로 중복 체크 필요시 별도 처리)
    emailError = email.contains('@') ? null : '유효한 이메일 형식이 아닙니다.';

    // 이름 유효성
    nameError = RegExp(r'^[가-힣]{2,10}$').hasMatch(name) ? null : '이름은 한글 2~10자여야 합니다.';

    // 생일 유효성
    birthdayError = _validateBirthday(birthday);

    final changed = (nickname != originalNickname) ||
        (password.isNotEmpty && password == confirmPassword && password != originalPassword) ||
        (email != originalEmail) ||
        (name != originalName) ||
        (birthday != originalBirthday);

    final allValid = nicknameError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        emailError == null &&
        nameError == null &&
        birthdayError == null;

    final newIsFormValid = changed && allValid;

    if (newIsFormValid != isFormValid) {
      setState(() {
        isFormValid = newIsFormValid;
      });
    }
  }
  String? _validateBirthday(String raw) {
    if (raw.length != 10 || !raw.contains('-')) return 'YYYY-MM-DD 형식이어야 합니다.';
    try {
      final parsed = DateTime.parse(raw);
      final now = DateTime.now();
      final age = now.year - parsed.year - ((now.month < parsed.month || (now.month == parsed.month && now.day < parsed.day)) ? 1 : 0);
      if (age < 0 || age > 120) return '나이 범위가 유효하지 않습니다.';
      return null;
    } catch (_) {
      return '생년월일 형식이 잘못되었습니다.';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // void _showPhotoOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (_) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.photo),
  //               title: const Text('사진 앨범에서 선택'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickImage();
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.close),
  //               title: const Text('취소'),
  //               onTap: () => Navigator.pop(context),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
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
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('프로필 사진 삭제'),
                onTap: () async {
                  Navigator.pop(context); // 먼저 닫고
                  final prefs = await SharedPreferences.getInstance();
                  final id = prefs.getString('loggedInId');
                  final token = prefs.getString('jwtToken');
                  if (id == null || token == null) return;

                  try {
                    final response = await dio.delete(
                      'http://10.0.2.2:8080/member/delete_image',
                      queryParameters: {'id': id},
                      options: Options(headers: {'Authorization': 'Bearer $token'}),
                    );
                    if (response.data == 1091) {
                      setState(() => _selectedImage = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("프로필 사진이 삭제되었습니다.")),
                      );
                    } else {
                      print("삭제 실패: ${response.data}");
                    }
                  } catch (e) {
                    print("삭제 오류: $e");
                  }
                },
              ),
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

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('loggedInId');
    try {
      final options = await _authOptions();

      if (id == null) {
        nicknameController.text = '비회원';
        setState(() => isLoading = false);
        return;
      }

      final response = await dio.get(
        'http://10.0.2.2:8080/member/get_member_object',
        queryParameters: {'id': id},
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data;
        nicknameController.text = data['nickname'] ?? '';
        originalNickname = nicknameController.text;
        passwordController.clear();
        confirmPasswordController.clear();
        originalPassword = data['password'] ?? '';
        emailController.text = data['email'] ?? '';
        originalEmail = emailController.text;
        nameController.text = data['name'] ?? '';
        originalName = nameController.text;
        birthdayController.text = data['birthday'] ?? '';
        originalBirthday = birthdayController.text;
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("회원 정보 로딩 실패: $e");
      nicknameController.text = '에러';
      setState(() => isLoading = false);
    }

    if (id != null) {
      await _loadProfileImage(id);
    }  // 프사 작업중
  }

  // 프사 작업중
  Future<void> _loadProfileImage(String id) async {
    final options = await _authOptions();
    try {
      final response = await dio.get<List<int>>(
        'http://10.0.2.2:8080/member/get_image',
        queryParameters: {'id': id},
        options: options.copyWith(responseType: ResponseType.bytes),
      );

      // if (response.statusCode == 200 && response.data != null) {
      //   setState(() {
      //     _selectedImage = File.fromRawPath(Uint8List.fromList(response.data!));
      //   });
      // } else {
      //   print("이미지 없음 또는 상태 코드 ${response.statusCode}");
      // }
      if (response.statusCode == 200 && response.data != null && response.data!.isNotEmpty) {
        setState(() {
          _selectedImage = File.fromRawPath(Uint8List.fromList(response.data!));
        });
      } else {
        print("기본 이미지 사용");
      }
    } catch (e) {
      print("이미지 로딩 실패: $e");
    }
  }


  Future<void> _handleSubmit() async {
    final nickname = nicknameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final birthday = birthdayController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('loggedInId');
    final options = await _authOptions();

    if (id == null) return;

    final data = {"id": id};
    if (nickname != originalNickname) data["nickname"] = nickname;
    if (password.isNotEmpty && password == confirmPasswordController.text && password != originalPassword) {
      data["password"] = password;
    }
    if (email != originalEmail) data["email"] = email;
    if (name != originalName) data["name"] = name;
    if (birthday != originalBirthday) data["birthday"] = birthday;

    try {
      final response = await dio.put(
        'http://10.0.2.2:8080/member/update',
        data: data,
        options: options,
      );

      if (response.data == 1030) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("수정 완료"),
            content: const Text("회원 정보가 성공적으로 수정되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
      } else {
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
    await _uploadProfileImage(id);  // 프사 작업중
  }

  // 프사 작업중
  Future<void> _uploadProfileImage(String id) async {
    if (_selectedImage == null) return; // 이미지 선택 안 했으면 업로드 X

    final fileName = _selectedImage!.path.split('/').last;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    print("🔥 업로드용 토큰: $token");
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(_selectedImage!.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        'http://10.0.2.2:8080/member/add_image/$id',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.data == 1070) {
        print('프로필 이미지 업로드 성공');
        await _loadProfileImage(id);
      } else {
        print('프로필 이미지 업로드 실패 코드: ${response.data}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
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
                        onPressed: _showPhotoOptions,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _labelText("별칭"),
              _textField(controller: nicknameController),
              const SizedBox(height: 16),
              _labelText("비밀번호"),
              _textField(controller: passwordController, obscure: true),
              const SizedBox(height: 16),
              _labelText("비밀번호 확인"),
              _textField(controller: confirmPasswordController, obscure: true),
              const SizedBox(height: 24),
              _labelText("이메일"),
              _textField(controller: emailController),
              const SizedBox(height: 16),
              _labelText("이름"),
              _textField(controller: nameController),
              const SizedBox(height: 16),
              _labelText("생일"),
              _textField(controller: birthdayController),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isFormValid ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("수정"),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("회원 탈퇴"),
                          content: const Text("정말 탈퇴하시겠습니까? 모든 데이터가 삭제됩니다."),
                          actions: [
                            TextButton(
                              child: const Text("취소"),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: const Text("확인"),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      final prefs = await SharedPreferences.getInstance();
                      final id = prefs.getString('loggedInId');

                      if (id == null) return;

                      try {
                        final response = await Dio().delete(
                          'http://10.0.2.2:8080/member/delete',
                          queryParameters: {'id': id},
                        );

                        if (response.data == 111111) {
                          await prefs.remove('loggedInId');
                          if (!context.mounted) return;
                          Navigator.of(context).popUntil((route) => route.isFirst); // 홈으로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("회원 탈퇴가 완료되었습니다.")),
                          );
                        } else {
                          print("탈퇴 실패 코드: ${response.data}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("탈퇴에 실패했습니다.")),
                          );
                        }
                      } catch (e) {
                        print("탈퇴 실패: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("서버 오류로 탈퇴에 실패했습니다.")),
                        );
                      }
                    },
                    child: const Text("회원탈퇴"),
                  ),
                ],
              ),
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

  Widget _textField({required TextEditingController controller, bool obscure = false, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}