import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'settings_page.dart';
import 'store.dart';
import 'collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/bottom_nav.dart';
import 'package:sodam/dio_client.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

String? selectedTitle;
String? selectedIcon;

class _MyPageState extends State<MyPage> {
  String nickname = '';
  String email = '';
  bool isLoading = true;
  // String title = ''; // 칭호

  int _walletPoint = 0;
  Set<DateTime> _attendedDates = {};

  Future<void> fetchAttendanceDates(String id) async {
    try {
      final response = await DioClient.dio.get(
        '/point/get_history_list',
        queryParameters: {'id': id},
      );

      if (response.data is List) {
        final List<dynamic> data = response.data;
        final Set<DateTime> result = {};

        for (final item in data) {
          if (item['point_change_reason_code'] == 'attendence') {
            final created = DateTime.parse(item['created_date']);
            result.add(DateTime(created.year, created.month, created.day)); // 시분초 제거
          }
        }

        setState(() {
          _attendedDates = result;
        });
      }
    } catch (e) {
      print("출석 데이터 불러오기 실패: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');
      print('🧩 저장된 ID: "$id"');

      if (id == null || id.trim().isEmpty) {
        print('⚠️ ID 없음 - 비회원 처리');
        setState(() {
          nickname = '비회원';
          email = '로그인 필요';
          isLoading = false;
          _walletPoint = 0;
        });
        return;
      }

      await fetchAttendanceDates(id);

      final response = await DioClient.dio.get('/member/get_member_object', queryParameters: {'id': id});
      // final pointResponse = await DioClient.dio.get('/point/get_info', queryParameters: {'id': id});
      final pointResponse = await DioClient.dio.get(
        '/point/get_info_id_object',
        queryParameters: {'id': id},
      );
      print("👤 member response: ${response.data}");
      print("💰 point response: ${pointResponse.data}");

      final memberData = response.data;
      final pointData = pointResponse.data;

      setState(() {
        nickname = memberData['nickname'] ?? '닉네임 없음';
        email = memberData['email'] ?? '이메일 없음';
        _walletPoint = (pointData is Map && pointData['current_point'] != null)
            ? pointData['current_point']
            : 0;
        selectedTitle = prefs.getString('selectedTitle');
        selectedIcon = prefs.getString('selectedIcon');
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio 요청 실패');
        print('📛 요청 경로: ${e.requestOptions.path}');
        print('📛 상태코드: ${e.response?.statusCode}');
        print('📛 응답본문: ${e.response?.data}');
        print('📛 응답타입: ${e.response?.headers.map['content-type']}');
      } else {
        print('❌ 예외: $e');
      }

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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.white,
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
                            backgroundImage: AssetImage('assets/images/gibon2.jpeg'),
                          ),
                          const SizedBox(height: 20),
                          if (selectedTitle != null)
                            Text(
                              selectedTitle!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          const SizedBox(height: 2),
                          // Text(nickname, style: const TextStyle(fontSize: 36)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (selectedIcon != null && selectedIcon!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    selectedIcon!,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              Text(
                                nickname,
                                style: const TextStyle(fontSize: 36),
                              ),
                              if (selectedIcon != null && selectedIcon!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Image.asset(
                                    selectedIcon!,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                            ],
                          ),
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const SettingsPage()),
                          // );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          ).then((result) {
                            if (result == true) {
                              fetchData(); // 새로고침
                            }
                          });
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
              _buildMarketButtons(),
              const SizedBox(height: 12),
              _buildCalendar(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildWallet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
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
                  final isAttended = _attendedDates.contains(
                    DateTime(day.year, day.month, day.day),
                  );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      isAttended
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.white,
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
            // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage())),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollectionPage()),
              ).then((result) {
                if (result == true) {
                  fetchData();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.white,
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