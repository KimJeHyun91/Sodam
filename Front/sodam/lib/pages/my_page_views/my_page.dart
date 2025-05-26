import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'settings_page.dart';
import 'store.dart';
import 'collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Dio 전역 설정
final dio = Dio();

void configureDio() {
  dio.options.baseUrl = 'http://10.0.2.2:8080'; // 에뮬레이터용
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);
  dio.options.headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String nickname = '';
  String email = '';
  bool isLoading = true;

  final Set<DateTime> _loginDates = {
    DateTime(2025, 5, 1),
    DateTime(2025, 5, 3),
    DateTime(2025, 5, 6),
  };

  int _walletPoint = 0;

  @override
  void initState() {
    super.initState();
    configureDio();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');

      if (id == null) {
        setState(() {
          nickname = '비회원';
          email = '로그인 필요';
          isLoading = false;
          _walletPoint = 0; // 포인트도 초기화
        });
        return;
      }

      // 닉네임, 이메일
      final response = await dio.get(
        '/member/get_member_object',
        queryParameters: {'id': id},
      );

      // 포인트
      final pointResponse = await dio.get(
        '/point/get_info',
        queryParameters: {'id': id},
      );

      if (response.data is Map<String, dynamic>) {
        setState(() {
          nickname = response.data['nickname'] ?? '닉네임 없음';
          email = response.data['email'] ?? '이메일 없음';
          _walletPoint = pointResponse.data['current_point'] ?? 0; // 포인트 설정
          isLoading = false;
        });
      } else {
        setState(() {
          nickname = '정보 없음';
          email = '정보 없음';
          _walletPoint = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('회원 정보 로딩 실패: $e');
      setState(() {
        nickname = '에러';
        email = '불러오기 실패';
        _walletPoint = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 프로필 카드
              Container(
                width: double.infinity,
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 100,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ),
                          const SizedBox(height: 20),
                          Text(nickname, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 6),
                          Text(email, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsPage()),
                          );
                        },
                        child: const Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _buildWallet(),
              const SizedBox(height: 12),
              _buildCalendar(),
              const SizedBox(height: 12),
              _buildMarketButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWallet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("지갑", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "$_walletPoint 냥",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("출석부", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 420, // 월 전체 달력 보이게
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) => "${date.month}월",
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isLoginDay = _loginDates.any((d) =>
                  d.year == day.year && d.month == day.month && d.day == day.day);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      isLoginDay
                          ? const Icon(Icons.star, size: 16, color: Colors.amber)
                          : const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorePage())),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text("장터", style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage())),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text("수집", style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}