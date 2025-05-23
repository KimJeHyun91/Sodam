import 'package:flutter/material.dart';
import '../main_page.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';


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

  // Dio 인스턴스 생성
  final dio = Dio();

  void configureDio() {
    // 기본 옵션 설정
    dio.options.baseUrl = '10.0.2.2:8080'; // 기본 URL
    dio.options.connectTimeout = Duration(seconds: 5); // 연결 타임아웃: 5초
    dio.options.receiveTimeout = Duration(seconds: 3); // 응답 수신 타임아웃: 3초
    dio.options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer YOUR_ACCESS_TOKEN', // 예시: 기본 인증 헤더
    };
    // dio.options.responseType = ResponseType.json; // 기본 응답 타입 (기본값은 json)
  }

  void main() {
    configureDio();
    // 이제 dio 인스턴스를 사용하여 API 호출
  }



  Future<void> postData() async {
    /*// 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return;
    }*/
    // 개인정보 동의 여부 확인
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보 수집 및 이용에 동의해주세요.')),
      );
      return;
    }

    // 1. UUID 생성
    var uuid = Uuid(); // Uuid 인스턴스 생성
    String newUuid = uuid.v4(); // v4 방식의 UUID 생성 (가장 일반적)
    // 또는 클래스 필드로 선언한 _uuidGenerator 사용:
    // String newUuid = _uuidGenerator.v4();

    // 컨트롤러에서 실제 데이터 가져오기
    Map<String, dynamic> memberInfo = {
      'id': _idController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
      'name': _nameController.text,
      'birthday': _birthController.text,
      'nickname': _nicknameController.text,
      'uuid': newUuid, // 2. 생성된 UUID를 member_info에 추가
      // 'authorization': 'U', // 서버에서 기본값을 설정하거나, 클라이언트에서 명시적으로 보낼 수 있습니다.
      // MemberDomain.java에는 authorization 필드가 있으므로 필요시 전송해야 합니다.
      // 기본값 'U'를 보내려면 주석 해제하세요.
    };

    // 로딩 인디케이터 보여주기 (선택 사항)
    // 예: showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));


    Response response = await dio.post(
        '/member/add', // 서버의 회원가입 API 엔드포인트
        data: memberInfo
    );
    print('Signup Success: ${response.data}');
    print('Generated UUID for user ${_idController.text}: $newUuid'); // 디버깅용 출력

    // 로딩 인디케이터 숨기기 (선택 사항)
    // if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    // 성공 시 다음 페이지로 이동 또는 사용자에게 성공 알림
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  bool agree = false;

  // 가짜 중복 확인용
  bool nicknameInUse = true;
  bool emailInUse = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 아이디
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('접속 이름 (아이디)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: 16),

                // 비밀번호
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('비밀번호', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '특수문자/숫자/영대문자/영소문자\n최소 1개씩 사용하여 7~20자',
                  ),
                ),
                const SizedBox(height: 16),

                // 비밀번호 확인
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('비밀번호 확인', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(),
                ),
                if (_confirmPasswordController.text.isNotEmpty &&
                    _confirmPasswordController.text != _passwordController.text)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),

                // 이름
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('이름', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                // 별칭
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('별칭', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _nicknameController,
                ),
                if (nicknameInUse)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '사용중인 별칭 입니다. / 부적합한 별칭입니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),

                // 생년월일
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('생년월일', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _birthController,
                  decoration: const InputDecoration(
                    hintText: 'ex) 2000/02/22',
                  ),
                ),
                const SizedBox(height: 16),

                // 이메일
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('손글주소', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'ex) sodam@naver.com',
                  ),
                ),
                if (emailInUse)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '가입 이력이 있는 이메일 입니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),

                // 동의 체크박스
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      onChanged: (val) {
                        setState(() {
                          agree = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text('소담톡 개인정보 수집 및 이용에 동의합니다.'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 가입완료 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9DAB2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      print(_passwordController);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainPage()),
                      );
                    },
                    child: const Text(
                      '가입완료',
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