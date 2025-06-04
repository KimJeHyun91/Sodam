import 'dart:io';

import 'package:flutter/foundation.dart';
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
  String nickname = '';
  String email = '';
  bool isLoading = true;

  String? selectedTitle;
  String? selectedIcon;
  String? selectedFrame;

  int _walletPoint = 0;

  Set<DateTime> _attendedDates = {};
  bool _isAttendedToday = false;

  final Dio dio = Dio();
  Uint8List? _originalImageBytes;
  File? _selectedImage;

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
      final pointNo = pointRes.data['point_no'];

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

        setState(() {
          _attendedDates = result;
        });
      }
    } catch (e) {
      print("출석 데이터 불러오기 실패: $e");
    }
  }

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> _loadProfileImage(String id) async {
    final options = await _authOptions();
    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/member/get_image',
        queryParameters: {'id': id},
        options: options.copyWith(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null && response.data.isNotEmpty) {
        setState(() {
          _originalImageBytes = Uint8List.fromList(response.data); // 서버 이미지
          _selectedImage = null; // 사용자가 직접 고르기 전까지는 null
        });
      } else {
        print("기본 이미지 사용");
        setState(() {
          // ✅ 이미지가 있지만, 여기서 _selectedImage는 null로 둬야 초기상태에서 변화를 안 감지함
          _selectedImage = null;
        });
      }
    } catch (e) {
      print("이미지 로딩 실패: $e");
    }
  }

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
              _walletPoint = newPoint;
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

      await _loadProfileImage(id); // 프로필 이미지 불러오는거

      final response = await DioClient.dio.get('/member/get_member_object', queryParameters: {'id': id});
      final pointResponse = await DioClient.dio.get('/point/get_info_id_object', queryParameters: {'id': id});

      final memberData = response.data;
      final pointData = pointResponse.data;

      final titleKey = 'selectedTitle_$id';
      final iconKey = 'selectedIcon_$id';
      final frameKey = 'selectedFrame_$id';
      print('🔍 프레임 경로: $selectedFrame');
      final attended = await fetchAttendanceStatus(id!);

      setState(() {
        nickname = memberData['nickname'] ?? '닉네임 없음';
        email = memberData['email'] ?? '이메일 없음';
        _walletPoint = (pointData is Map && pointData['current_point'] != null)
            ? pointData['current_point']
            : 0;
        selectedTitle = prefs.getString(titleKey);
        selectedIcon = prefs.getString(iconKey);
        selectedFrame = prefs.getString(frameKey);
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
                height: 430,
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
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (selectedFrame != null && selectedFrame!.isNotEmpty)
                                Image.asset(
                                  selectedFrame!,
                                  width: 300,
                                  height: 300,
                                ),
                              CircleAvatar(
                                radius: 92,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : _originalImageBytes != null
                                    ? MemoryImage(_originalImageBytes!)
                                    : const AssetImage('assets/images/gibon2.jpeg') as ImageProvider,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
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
              _buildAttendanceButton(),
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
              locale: 'ko_KR',
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              rowHeight: 55,
              daysOfWeekHeight: 32,
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

  // Widget _buildMarketButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: GestureDetector(
  //           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorePage())),
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(vertical: 24),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).brightness == Brightness.dark
  //                   ? Colors.grey[850]
  //                   : Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             alignment: Alignment.center,
  //             child: const Text("장터", style: TextStyle(fontSize: 18)),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: GestureDetector(
  //           // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage())),
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (_) => const CollectionPage()),
  //             ).then((result) {
  //               if (result == true) {
  //                 fetchData();
  //               }
  //             });
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(vertical: 24),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).brightness == Brightness.dark
  //                   ? Colors.grey[850]
  //                   : Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             alignment: Alignment.center,
  //             child: const Text("수집", style: TextStyle(fontSize: 18)),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildMarketButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StorePage()),
              ).then((result) {
                if (result == true) {
                  fetchData(); // ✅ 상점에서 적용 후 돌아오면 새로고침
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
              child: const Text("장터", style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollectionPage()),
              ).then((result) {
                if (result == true) {
                  fetchData(); // ✅ 수집에서도 동일하게 새로고침
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