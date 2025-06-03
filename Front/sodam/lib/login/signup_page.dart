// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'login_page.dart';
// import '../dio_client.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _idController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _nicknameController = TextEditingController();
//   final _birthController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _emailCodeController = TextEditingController();
//
//   bool agree = false;
//   bool idAvailable = false;
//   bool idChecked = false;
//   bool idValid = false;
//   bool passwordValid = false;
//   bool passwordConfirmed = false;
//   bool nicknameInUse = false;
//   bool emailInUse = false;
//   bool _isFormatting = false;
//   bool emailVerified = false;
//
//   bool idTouched = false;
//   bool passwordTouched = false;
//   bool _birthTouched = false;
//
//   bool isPasswordTooSimilarToId(String id, String pw) {
//     for (int i = 0; i <= id.length - 4; i++) {
//       final slice = id.substring(i, i + 4);
//       if (pw.contains(slice)) return true;
//     }
//     return false;
//   }
//
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     _idController.addListener(_onIdChanged);
//     _passwordController.addListener(_onPasswordChanged);
//     _confirmPasswordController.addListener(_onPasswordConfirmChanged);
//     _nameController.addListener(_onNameChanged);
//     _nicknameController.addListener(_onNicknameChanged);
//     _birthController.addListener(_onBirthChanged);
//   }
//
//   void _onIdChanged() {
//     final id = _idController.text.trim();
//     final idRegex = RegExp(r'^(?=.*[a-z])[a-z0-9]{6,15}$');
//
//     if (!idTouched && id.isNotEmpty) {
//       setState(() {
//         idTouched = true;
//       });
//     }
//
//     final valid = idRegex.hasMatch(id); // ✅ 즉시 검사
//     setState(() {
//       idValid = valid;
//       idChecked = false;
//       _idError = (!idTouched || valid) ? null : '아이디는 영소문자 포함 6~15자여야 합니다.';
//     });
//
//     if (!valid) {
//       setState(() {
//         _idError = '아이디는 영소문자 포함 6~15자여야 합니다.';
//       });
//       return;
//     }
//
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       try {
//         final response = await DioClient.dio.get('/member/id_check', queryParameters: {'id': id});
//         final available = response.data == 1010;
//         setState(() {
//           idAvailable = available;
//           idChecked = true;
//           _idError = available ? null : '이미 사용 중인 아이디입니다.';
//         });
//       } catch (e) {
//         setState(() {
//           idAvailable = false;
//           idChecked = true;
//           _idError = '아이디 확인 요청 실패';
//         });
//       }
//     });
//   }
//
//   void _onPasswordChanged() {
//     final id = _idController.text;
//     final pw = _passwordController.text;
//     final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_]).{8,16}$');
//
//     final isValid = regex.hasMatch(pw);
//     final isSimilar = isPasswordTooSimilarToId(id, pw);
//
//     setState(() {
//       passwordTouched = pw.isNotEmpty;
//
//       // 조건 미충족 또는 아이디 유사도 체크는 입력 시작 후부터만
//       if (!passwordTouched) {
//         _passwordError = null;
//         passwordValid = false;
//       } else if (!isValid) {
//         _passwordError = '조건에 맞지 않습니다.';
//         passwordValid = false;
//       } else if (isSimilar) {
//         _passwordError = '비밀번호에 아이디와 동일한 문자열이 포함되어 있습니다.';
//         passwordValid = false;
//       } else {
//         _passwordError = null;
//         passwordValid = true;
//       }
//     });
//   }
//
//   void _onPasswordConfirmChanged() {
//     setState(() {
//       passwordConfirmed = _passwordController.text == _confirmPasswordController.text;
//     });
//   }
//
//   void _onNameChanged() {
//     final name = _nameController.text.trim();
//     final nameRegex = RegExp(r'^[가-힣]{2,10}$');
//     setState(() {
//       _nameError = name.isEmpty || nameRegex.hasMatch(name)
//           ? null
//           : '이름은 한글 2~10자여야 합니다.';
//     });
//   }
//
//   void _onNicknameChanged() {
//     final nick = _nicknameController.text.trim();
//     final nickRegex = RegExp(r'^(?:[가-힣]{2,8}\d{0,4}|\d{1,4})$');
//     setState(() {
//       _nicknameError = nick.isEmpty || nickRegex.hasMatch(nick)
//           ? null
//           : '별칭은 한글 2~8자, 숫자 0~4자리만 가능합니다.';
//     });
//   }
//
//   void _onBirthChanged() {
//     if (_isFormatting) return;
//
//     final raw = _birthController.text;
//
//     if (raw.length == 10 && raw.contains('-')) return;
//
//     if (!_birthTouched && raw.isNotEmpty) {
//       setState(() {
//         _birthTouched = true;
//       });
//     }
//
//     // 입력 전이면 아무 검증도 하지 않음
//     if (!_birthTouched) return;
//
//     if (raw.length != 8) {
//       setState(() {
//         _birthError = '생년월일이 정확한지 확인해 주세요.';
//       });
//       return;
//     }
//
//     final year = int.tryParse(raw.substring(0, 4));
//     final month = int.tryParse(raw.substring(4, 6));
//     final day = int.tryParse(raw.substring(6, 8));
//
//     if (year == null || month == null || day == null) {
//       setState(() {
//         _birthError = '생년월일이 정확한지 확인해 주세요.';
//       });
//       return;
//     }
//
//     try {
//       final parsedDate = DateTime(year, month, day);
//
//       if (parsedDate.year != year ||
//           parsedDate.month != month ||
//           parsedDate.day != day) {
//         setState(() {
//           _birthError = '생년월일이 정확한지 확인해 주세요.';
//         });
//         return;
//       }
//
//       final now = DateTime.now();
//       final age = now.year -
//           parsedDate.year -
//           ((now.month < parsedDate.month ||
//               (now.month == parsedDate.month && now.day < parsedDate.day))
//               ? 1
//               : 0);
//
//       if (age < 0 || age > 120) {
//         setState(() {
//           _birthError = '생년월일이 정확한지 확인해 주세요.';
//         });
//         return;
//       }
//       final formatted =
//           '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}';
//       _isFormatting = true;
//       _birthController.value = TextEditingValue(
//         text: formatted,
//         selection: TextSelection.collapsed(offset: formatted.length),
//       );
//       _isFormatting = false;
//
//       // 에러 없앰 (중복 제거 위해 frame callback에 추가)
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _birthError = null;
//           });
//         }
//       });
//     } catch (_) {
//       setState(() {
//         _birthError = '생년월일이 정확한지 확인해 주세요.';
//       });
//     }
//   }
//
//   void _sendVerificationCode() async {
//     final email = _emailController.text.trim();
//     if (email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('이메일을 입력해주세요.')),
//       );
//       return;
//     }
//
//     try {
//       final response = await DioClient.dio.post(
//
//         '/auth/send-code-signup',
//         data: {'email': email},
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response.data['message'] ?? '인증번호가 전송되었습니다.')),
//       );
//
//
//       setState(() {
//         _codeVerified = false;
//         _emailVerifyError = null;
//       });
//       _startEmailTimer();
//
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ 이메일 전송 실패: ${e.toString()}')),
//       );
//     }
//
//   }
//
//   void _verifyEmailCode() async {
//     final email = _emailController.text.trim();
//     final code = _emailCodeController.text.trim();
//
//     if (email.isEmpty || code.isEmpty) {
//       setState(() {
//         _emailVerifyError = '이메일과 인증번호를 모두 입력해주세요.';
//       });
//       return;
//     }
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('jwt_token');
//
//       final response = await DioClient.dio.post(
//         '/auth/verify-code',
//         data: {
//           'email': email,
//           'code': code,
//         },
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.data['status'] == 'success') {
//         setState(() {
//           emailVerified = true;
//           _codeVerified = true;
//           _emailVerifyError = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response.data['message'] ?? '인증 성공')),
//         );
//       } else {
//         setState(() {
//           _emailVerifyError = response.data['message'] ?? '인증번호가 일치하지 않습니다.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _emailVerifyError = '인증번호가 일치하지 않습니다';
//       });
//     }
//   }
//
//
//   bool canSubmit() {
//     return idValid && idChecked && idAvailable &&
//         passwordTouched && passwordValid && passwordConfirmed &&
//         _nameError == null && _nicknameError == null && !nicknameInUse &&
//         _birthError == null &&
//         _emailController.text.trim().isNotEmpty && !emailInUse && emailVerified &&
//         agree;
//   }
//
//   Future<void> _signup() async {
//     if (!agree) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('개인정보 수집에 동의해주세요.')),
//       );
//       return;
//     }
//     if (!idValid || !idChecked || !idAvailable ||
//         !passwordValid || !passwordConfirmed ||
//         _nameError != null || _nicknameError != null || nicknameInUse ||
//         _birthError != null || emailInUse ||
//         !agree) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('입력값을 다시 확인해주세요.')),
//       );
//       return;
//     }
//
//     try {
//       final response = await DioClient.dio.post(
//         '/member/add',
//         data: {
//           'id': _idController.text,
//           'password': _passwordController.text,
//           'name': _nameController.text,
//           'nickname': _nicknameController.text,
//           'birthday': _birthController.text,
//           'email': _emailController.text,
//         },
//       );
//       if (context.mounted) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('loggedInId', _idController.text);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('회원가입 성공')),
//         );
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _idController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameController.dispose();
//     _nicknameController.dispose();
//     _birthController.dispose();
//     _emailController.dispose();
//     _emailCodeController.dispose();
//     _debounce?.cancel();
//     _emailTimer?.cancel();
//     super.dispose();
//   }
//   Timer? _emailTimer;
//   int _timeLeft = 180; // 3분
//   bool _codeVerified = false;
//
//   void _startEmailTimer() {
//     _emailTimer?.cancel();
//     setState(() {
//       _timeLeft = 180;
//     });
//     _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_timeLeft <= 0) {
//         timer.cancel();
//         setState(() {
//           _emailVerifyError = '인증 시간이 초과되었습니다.';
//         });
//       } else {
//         setState(() {
//           _timeLeft--;
//         });
//       }
//     });
//   }
//
//   String _formatTimeLeft() {
//     final minutes = _timeLeft ~/ 60;
//     final seconds = _timeLeft % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }
//   Widget _buildTimerText() {
//     if (_codeVerified || _timeLeft <= 0) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(top: 4.0),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           '남은 시간: ${_formatTimeLeft()}',
//           style: const TextStyle(color: Colors.blue),
//         ),
//       ),
//     );
//   }
//   Widget _buildStatusText(bool condition, String successText, String failText) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         condition ? successText : failText,
//         style: TextStyle(color: condition ? Colors.green : Colors.red),
//       ),
//     );
//   }
//
//   String? _idError;
//   String? _passwordError;
//   String? _nameError;
//   String? _nicknameError;
//   String? _birthError;
//   String? _emailVerifyError;
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData.light().copyWith(brightness: Brightness.light),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//
//                   // ID
//                   const Align(alignment: Alignment.centerLeft, child: Text('접속 이름')),
//                   TextFormField(
//                     controller: _idController,
//                     decoration: InputDecoration(
//                       hintText: '영소문자 포함 6~15자',
//                       errorText: idTouched ? _idError : null, // 작성 전이면 null, 틀리면 메시지
//                     ),
//                   ),
//                   if (idTouched && idValid && idChecked && idAvailable)
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         '사용 가능한 아이디입니다.',
//                         style: const TextStyle(color: Colors.green),
//
//                       ),
//                     ),
//                   const SizedBox(height: 16),
//
//                   // Password
//                   const Align(alignment: Alignment.centerLeft, child: Text('비밀번호')),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: '영문자+숫자+특수문자 포함, 8~16자리',
//                       errorText: _passwordError,
//                     ),
//                   ),
//                   if (passwordTouched && passwordValid)
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: const Text('사용 가능한 비밀번호입니다.', style: TextStyle(color: Colors.green)),
//                     ),
//
//                   // Confirm password
//                   const Align(alignment: Alignment.centerLeft, child: Text('비밀번호 확인')),
//                   TextFormField(controller: _confirmPasswordController, obscureText: true),
//                   if (_confirmPasswordController.text.isNotEmpty)
//                     _buildStatusText(passwordConfirmed, '', '비밀번호가 일치하지 않습니다.'),
//                   const SizedBox(height: 16),
//
//                   // Name
//                   const Align(alignment: Alignment.centerLeft, child: Text('이름')),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       errorText: _nameError,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Nickname
//                   const Align(alignment: Alignment.centerLeft, child: Text('별칭')),
//                   TextFormField(
//                     controller: _nicknameController,
//                     decoration: InputDecoration(
//                       errorText: _nicknameError,
//                     ),
//                   ),
//                   if (nicknameInUse)
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('사용중인 별칭입니다.', style: TextStyle(color: Colors.red)),
//                     ),
//                   const SizedBox(height: 16),
//
//                   // Birthday
//                   // 생년월일 입력
//                   const Align(alignment: Alignment.centerLeft, child: Text('생년월일 (8자리)')),
//                   TextFormField(
//                     controller: _birthController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(8),
//                     ],
//                     decoration: InputDecoration(
//                       hintText: '예: 19940428',
//                       errorText: _birthError,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Email
//                   const Align(alignment: Alignment.centerLeft, child: Text('손글주소')),
//                   TextFormField(controller: _emailController),
//                   if (emailInUse)
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('이미 등록된 이메일입니다.', style: TextStyle(color: Colors.red)),
//                     ),
//                   const SizedBox(height: 16),
//
//                   // 이메일 입력 아래에 추가
//                   Row(
//                     children: [
//                       // 인증번호 입력 칸
//                       Expanded(
//                         child: TextFormField(
//                           controller: _emailCodeController,
//                           decoration: const InputDecoration(
//                             hintText: '인증번호 입력',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//
//                       // 인증번호 발송 버튼
//                       ElevatedButton(
//                         onPressed: _sendVerificationCode,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD3E3BC),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                         ),
//                         child: const Text(
//                           '인증번호 받기',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//
//
//                       // ✅ 인증번호 확인 버튼
//                       ElevatedButton(
//                         onPressed: _verifyEmailCode,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFCCE5FF),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                         ),
//                         child: const Text(
//                           '확인',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // ✅ 인증 실패 메시지 출력 (Row 바깥)
//                   if (_emailVerifyError != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4.0),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           _emailVerifyError!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),
//                     ),
//
//                   _buildTimerText(),
//
//
//                   // 개인정보 동의
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: agree,
//                         onChanged: (val) => setState(() => agree = val ?? false),
//                       ),
//                       const Text('개인정보 수집 및 이용에 동의합니다.'),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Submit button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: canSubmit() ? _signup : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: canSubmit() ? const Color(0xFFD3E3BC) : Colors.grey[300], // 활성: 연두 / 비활성: 회색
//                         foregroundColor: Colors.black, // 텍스트 색
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         textStyle: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('가입완료'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login_page.dart';
import '../dio_client.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();

  bool agree = false;
  bool idAvailable = false;
  bool idChecked = false;
  bool idValid = false;
  bool passwordValid = false;
  bool passwordConfirmed = false;
  bool nicknameInUse = false;
  bool emailInUse = false;
  bool _isFormatting = false;
  bool emailVerified = false;

  bool idTouched = false;
  bool passwordTouched = false;
  bool _birthTouched = false;
  bool birthEntered = false;

  bool isPasswordTooSimilarToId(String id, String pw) {
    for (int i = 0; i <= id.length - 4; i++) {
      final slice = id.substring(i, i + 4);
      if (pw.contains(slice)) return true;
    }
    return false;
  }

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordConfirmChanged);
    _nameController.addListener(_onNameChanged);
    _nicknameController.addListener(_onNicknameChanged);
    _birthController.addListener(_onBirthChanged);
  }

  void _onIdChanged() {
    final id = _idController.text.trim();
    final idRegex = RegExp(r'^(?=.*[a-z])[a-z0-9]{6,15}$');

    if (!idTouched && id.isNotEmpty) {
      setState(() {
        idTouched = true;
      });
    }

    final valid = idRegex.hasMatch(id); // ✅ 즉시 검사
    setState(() {
      idValid = valid;
      idChecked = false;
      _idError = (!idTouched || valid) ? null : '아이디는 영소문자 포함 6~15자여야 합니다.';
    });

    if (!valid) {
      setState(() {
        _idError = '아이디는 영소문자 포함 6~15자여야 합니다.';
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await DioClient.dio.get('/member/id_check', queryParameters: {'id': id});
        final available = response.data == 1010;
        setState(() {
          idAvailable = available;
          idChecked = true;
          _idError = available ? null : '이미 사용 중인 아이디입니다.';
        });
      } catch (e) {
        setState(() {
          idAvailable = false;
          idChecked = true;
          _idError = '아이디 확인 요청 실패';
        });
      }
    });
  }

  void _onPasswordChanged() {
    final id = _idController.text;
    final pw = _passwordController.text;
    final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_]).{8,16}$');

    final isValid = regex.hasMatch(pw);
    final isSimilar = isPasswordTooSimilarToId(id, pw);

    setState(() {
      passwordTouched = pw.isNotEmpty;

      // 조건 미충족 또는 아이디 유사도 체크는 입력 시작 후부터만
      if (!passwordTouched) {
        _passwordError = null;
        passwordValid = false;
      } else if (!isValid) {
        _passwordError = '조건에 맞지 않습니다.';
        passwordValid = false;
      } else if (isSimilar) {
        _passwordError = '비밀번호에 아이디와 동일한 문자열이 포함되어 있습니다.';
        passwordValid = false;
      } else {
        _passwordError = null;
        passwordValid = true;
      }
    });
  }

  void _onPasswordConfirmChanged() {
    setState(() {
      passwordConfirmed = _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    final nameRegex = RegExp(r'^[가-힣]{2,10}$');
    setState(() {
      _nameError = name.isEmpty || nameRegex.hasMatch(name)
          ? null
          : '이름은 한글 2~10자여야 합니다.';
    });
  }

  void _onNicknameChanged() {
    final nick = _nicknameController.text.trim();
    final nickRegex = RegExp(r'^(?:[가-힣]{2,8}\d{0,4}|\d{1,4})$');
    setState(() {
      _nicknameError = nick.isEmpty || nickRegex.hasMatch(nick)
          ? null
          : '별칭은 한글 2~8자, 숫자 0~4자리만 가능합니다.';
    });
  }

  void _onBirthChanged() {
    if (_isFormatting) return;

    final raw = _birthController.text;

    if (raw.length == 10 && raw.contains('-')) return;

    if (!_birthTouched && raw.isNotEmpty) {
      setState(() {
        _birthTouched = true;
        birthEntered = true;
      });
    }

    // 입력 전이면 아무 검증도 하지 않음
    if (!_birthTouched) return;

    if (raw.length != 8) {
      setState(() {
        _birthError = '생년월일이 정확한지 확인해 주세요.';
      });
      return;
    }

    final year = int.tryParse(raw.substring(0, 4));
    final month = int.tryParse(raw.substring(4, 6));
    final day = int.tryParse(raw.substring(6, 8));

    if (year == null || month == null || day == null) {
      setState(() {
        _birthError = '생년월일이 정확한지 확인해 주세요.';
      });
      return;
    }

    try {
      final parsedDate = DateTime(year, month, day);

      if (parsedDate.year != year ||
          parsedDate.month != month ||
          parsedDate.day != day) {
        setState(() {
          _birthError = '생년월일이 정확한지 확인해 주세요.';
        });
        return;
      }

      final now = DateTime.now();
      final age = now.year -
          parsedDate.year -
          ((now.month < parsedDate.month ||
              (now.month == parsedDate.month && now.day < parsedDate.day))
              ? 1
              : 0);

      if (age < 0 || age > 120) {
        setState(() {
          _birthError = '생년월일이 정확한지 확인해 주세요.';
        });
        return;
      }
      final formatted =
          '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}';
      _isFormatting = true;
      _birthController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isFormatting = false;

      // 에러 없앰 (중복 제거 위해 frame callback에 추가)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _birthError = null;
          });
        }
      });
    } catch (_) {
      setState(() {
        _birthError = '생년월일이 정확한지 확인해 주세요.';
      });
    }
  }

  void _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력해주세요.')),
      );
      return;
    }

    try {
      final response = await DioClient.dio.post(

        '/auth/send-code-signup',
        data: {'email': email},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.data['message'] ?? '인증번호가 전송되었습니다.')),
      );


      setState(() {
        _codeVerified = false;
        _emailVerifyError = null;
      });
      _startEmailTimer();


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 이메일 전송 실패: ${e.toString()}')),
      );
    }

  }

  void _verifyEmailCode() async {
    final email = _emailController.text.trim();
    final code = _emailCodeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      setState(() {
        _emailVerifyError = '이메일과 인증번호를 모두 입력해주세요.';
      });
      return;
    }

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');


      final response = await DioClient.dio.post(
        '/auth/verify-code',
        data: {
          'email': email,
          'code': code,
        },

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),

      );

      if (response.data['status'] == 'success') {
        setState(() {

          emailVerified = true;
          _codeVerified = true;
          _emailVerifyError = null;

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? '인증 성공')),
        );
      } else {
        setState(() {
          _emailVerifyError = response.data['message'] ?? '인증번호가 일치하지 않습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _emailVerifyError = '인증번호가 일치하지 않습니다';
      });
    }

  }


  bool canSubmit() {
    return idValid && idChecked && idAvailable &&
        passwordTouched && passwordValid && passwordConfirmed &&
        _nameController.text.trim().isNotEmpty && _nameError == null &&
        _nicknameController.text.trim().isNotEmpty && _nicknameError == null && !nicknameInUse &&
        _birthController.text.trim().isNotEmpty && _birthError == null &&

        _emailController.text.trim().isNotEmpty && !emailInUse && emailVerified &&
        agree;
  }

  Future<void> _signup() async {
    if (!canSubmit()) {
      final msg = !agree
          ? '개인정보 수집에 동의해주세요.'
          : '입력값을 다시 확인해주세요.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    try {
      final response = await DioClient.dio.post(
        '/member/add',
        data: {
          'id': _idController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'nickname': _nicknameController.text,
          'birthday': _birthController.text,
          'email': _emailController.text,
        },
      );
      if (context.mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInId', _idController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _emailCodeController.dispose();
    _debounce?.cancel();
    _emailTimer?.cancel();
    super.dispose();
  }
  Timer? _emailTimer;
  int _timeLeft = 180; // 3분
  bool _codeVerified = false;

  void _startEmailTimer() {
    _emailTimer?.cancel();
    setState(() {
      _timeLeft = 180;
    });
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() {
          _emailVerifyError = '인증 시간이 초과되었습니다.';
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
    if (_codeVerified || _timeLeft <= 0) return const SizedBox.shrink();
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
  Widget _buildStatusText(bool condition, String successText, String failText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        condition ? successText : failText,
        style: TextStyle(color: condition ? Colors.green : Colors.red),
      ),
    );
  }

  String? _idError;
  String? _passwordError;
  String? _nameError;
  String? _nicknameError;
  String? _birthError;
  String? _emailVerifyError;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // ID
                  const Align(alignment: Alignment.centerLeft, child: Text('접속 이름')),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: '영소문자 포함 6~15자',
                      errorText: idTouched ? _idError : null, // 작성 전이면 null, 틀리면 메시지
                    ),
                  ),
                  if (idTouched && idValid && idChecked && idAvailable)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '사용 가능한 아이디입니다.',
                        style: const TextStyle(color: Colors.green),

                      ),
                    ),
                  const SizedBox(height: 16),

                  // Password
                  const Align(alignment: Alignment.centerLeft, child: Text('비밀번호')),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '영문자+숫자+특수문자 포함, 8~16자리',
                      errorText: _passwordError,
                    ),
                  ),
                  if (passwordTouched && passwordValid)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('사용 가능한 비밀번호입니다.', style: TextStyle(color: Colors.green)),
                    ),

                  // Confirm password
                  const Align(alignment: Alignment.centerLeft, child: Text('비밀번호 확인')),
                  TextFormField(controller: _confirmPasswordController, obscureText: true),
                  if (_confirmPasswordController.text.isNotEmpty)
                    _buildStatusText(passwordConfirmed, '', '비밀번호가 일치하지 않습니다.'),
                  const SizedBox(height: 16),

                  // Name
                  const Align(alignment: Alignment.centerLeft, child: Text('이름')),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      errorText: _nameError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nickname
                  const Align(alignment: Alignment.centerLeft, child: Text('별칭')),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      errorText: _nicknameError,
                    ),
                  ),
                  if (nicknameInUse)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('사용중인 별칭입니다.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),

                  // Birthday
                  // 생년월일 입력
                  const Align(alignment: Alignment.centerLeft, child: Text('생년월일 (8자리)')),
                  TextFormField(
                    controller: _birthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      hintText: '예: 19940428',
                      errorText: _birthError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  const Align(alignment: Alignment.centerLeft, child: Text('손글주소')),
                  TextFormField(controller: _emailController),
                  if (emailInUse)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('이미 등록된 이메일입니다.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),

                  // 이메일 입력 아래에 추가
                  Row(
                    children: [
                      // 인증번호 입력 칸
                      Expanded(
                        child: TextFormField(
                          controller: _emailCodeController,
                          decoration: const InputDecoration(
                            hintText: '인증번호 입력',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 인증번호 발송 버튼
                      ElevatedButton(
                        onPressed: _sendVerificationCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD3E3BC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: const Text(
                          '인증번호 받기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 8),


                      // ✅ 인증번호 확인 버튼
                      ElevatedButton(
                        onPressed: _verifyEmailCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCE5FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  // ✅ 인증 실패 메시지 출력 (Row 바깥)
                  if (_emailVerifyError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _emailVerifyError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                  _buildTimerText(),


                  // 개인정보 동의
                  Row(
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (val) => setState(() => agree = val ?? false),
                      ),
                      const Text('개인정보 수집 및 이용에 동의합니다.'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canSubmit() ? _signup : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSubmit() ? const Color(0xFFD3E3BC) : Colors.grey[300], // 활성: 연두 / 비활성: 회색
                        foregroundColor: Colors.black, // 텍스트 색
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('가입완료'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}