import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sodam/myPage/point_history_page.dart';
import '../websocket_service.dart';
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

class _MyPageState extends State<MyPage> {
  int? currentPoint;
  int? myPoint;

  String nickname = '';
  String email = '';
  bool isLoading = true;

  String? selectedTitle;
  String? selectedIcon;

  int _walletPoint = 0;

  Set<DateTime> _attendedDates = {};
  bool _isAttendedToday = false;

  void increasePoint(int earned) {
    setState(() {
      _walletPoint += earned;
    });
  }

  Future<bool> fetchAttendanceStatus(String id) async {

    try {
      final response = await DioClient.dio.get(
        '/point/get_history_list',
        queryParameters: {'id': id},
      );

      if (response.data is List) {
        final List<dynamic> data = response.data;
        final today = DateTime.now();
        final todayKey = DateTime(today.year, today.month, today.day);

        for (final item in data) {
          if (item['point_change_reason_code'] == 'attendence') {
            final created = DateTime.parse(item['created_date']);
            final createdKey = DateTime(created.year, created.month, created.day);

            if (createdKey == todayKey) return true; // 오늘 출석함
          }
        }
      }
      return false; // 오늘 출석 안함
    } catch (e) {
      print("🔥 출석 여부 확인 실패: $e");
      return false;
    }
  }

  Future<void> fetchAttendanceDates(String id) async {
    try {
      // 1. 유저의 point_no 가져오기
      final pointRes = await DioClient.dio.get(
        '/point/get_info_id_object',
        queryParameters: {'id': id},
      );
      final pointNo = pointRes.data['data']['point_no'];

      // 2. point_no 기반 히스토리만 요청
      final historyRes = await DioClient.dio.get('/point/get_history_point_no_list', queryParameters: {'id': id});

      if (historyRes.data is List) {
        final List<dynamic> data = historyRes.data;
        final Set<DateTime> result = {};

        for (final item in data) {
          if (item['point_change_reason_code'] == 'attendence') {
            final created = DateTime.parse(item['created_date']);
            result.add(DateTime(created.year, created.month, created.day)); // 시분초 제거
          }
        }

        setState(() {_attendedDates = result;});
      }
    } catch (e) {
      print("출석 데이터 불러오기 실패: $e");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  // }
  @override
  void initState() {
    super.initState();

    fetchData().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');

      if (id != null) {
        WebSocketService.connect(
          userId: id,
          onPointUpdate: (newPoint) {
            setState(() {
              _walletPoint = newPoint; // 지갑 실시간 반영!
            });
          },
        );
      }
    });
  }

  Future<void> _handleAttend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');
      if (id == null) return;

      // point_no 조회
      final pointRes = await DioClient.dio.get('/point/get_info_id_object', queryParameters: {'id': id});
      print('📦 pointRes: ${pointRes.data}');
      final pointNo = pointRes.data['point_no'];

      // 포인트 지급 요청
      final attendRes = await DioClient.dio.post('/point/create_history', data: {
        'point_no': pointNo,
        'change_amount': 10,
        'point_plus_minus': 'P',
        'point_change_reason_code': 'attendence',
      });

      if (attendRes.statusCode == 200 || attendRes.data == 11) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🎉 출석 완료! 10냥 지급됨")));
        await fetchData(); // 출석 여부 새로고침 (포인트 + 도장)
      } else {
        throw Exception("출석 실패");
      }
    } catch (e) {
      print("출석 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ 출석에 실패했어요")));
    }
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');
      final isGuest = prefs.get('isGuest') == true;
      final guestNickname = prefs.getString('guest_nickname') ?? '비회원';

      print('🧩 저장된 ID: "$id", isGuest: $isGuest');

      if (isGuest || id == null || id.trim().isEmpty) {
        print('⚠️ 비회원 처리');
        setState(() {
          nickname = guestNickname;
          email = '로그인 필요';
          isLoading = false;
          _walletPoint = 0;
        });
        return;
      }

      await fetchAttendanceDates(id);
      await fetchPoint();

      final response = await DioClient.dio.get('/member/get_member_object', queryParameters: {'id': id});
      final pointResponse = await DioClient.dio.get('/point/get_info_id_object', queryParameters: {'id': id});

      final memberData = response.data;
      final pointData = pointResponse.data;

      final titleKey = 'selectedTitle_$id';
      final iconKey = 'selectedIcon_$id';

      final attended = await fetchAttendanceStatus(id!);

      setState(() {
        nickname = memberData['nickname'] ?? '닉네임 없음';
        email = memberData['email'] ?? '이메일 없음';
        _walletPoint = (pointData is Map && pointData['current_point'] != null)
            ? pointData['current_point']
            : 0;
        selectedTitle = prefs.getString(titleKey);
        selectedIcon = prefs.getString(iconKey);
        isLoading = false;
        _isAttendedToday = attended;
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

  Future<void> fetchPoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId');
      if (id == null) return;

      final response = await DioClient.dio.get('/point/get_info_id_object', queryParameters: {'id': id});
      final data = response.data;

      // ✅ 방어 코드 추가
      if (data is! Map || !data.containsKey('current_point')) {
        print('❌ current_point 없음 또는 응답 형식 문제: $data');
        return;
      }

      final point = data['current_point'];

      setState(() {
        myPoint = point;
      });
    } catch (e) {
      print("엽전 가져오기 실패: $e");
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
              const SizedBox(height: 12),
              _buildAttendanceButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildWallet() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PointHistoryPage()),
        );
      },
      child: Container(
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
            const SizedBox(height: 8),
            if (myPoint != null)
              Text("✨ 현재 보유 엽전: $myPoint 냥", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButton() {
    return ElevatedButton(
      onPressed: _isAttendedToday ? null : _handleAttend,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isAttendedToday ? Colors.grey : Colors.greenAccent,
      ),
      child: Text(_isAttendedToday ? "출석 완료!" : "출석하기"),
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
                todayTextStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent, // ← 파란 동그라미 제거
                ),
                defaultDecoration: BoxDecoration(
                  color: Colors.transparent, // ← 회색 동그라미 제거
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, focusedDay) {
                  final isAttended = _attendedDates.contains(
                    DateTime(day.year, day.month, day.day),
                  );

                  if (isAttended) {
                    return Positioned(
                      bottom: 4,
                      child: Icon(Icons.star, size: 16, color: Colors.amber),
                    );
                  }

                  return null;
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