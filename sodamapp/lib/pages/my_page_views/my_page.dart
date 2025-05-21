import 'package:flutter/material.dart';
import 'settings_page.dart';
import '../store.dart';
import '../collection.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 전체 여백 통일
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
                      // 중앙 콘텐츠
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: AssetImage('assets/images/profile.png'),
                            ),
                            const SizedBox(height: 20),
                            const Text("키무키찬", style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 6),
                            // const Text("손글주소 :", style: TextStyle(fontSize: 14)),
                            const Text("kimukichan@gmail.com", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),

                      // 설정 아이콘 – 우측 상단 고정
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

                // 복주머니
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("지갑", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text("2,580 냥", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 출석부
                Container(
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
                      _buildCalendar(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 장터
                Row(
                  children: [
                    // 왼쪽: 장터
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StorePage()),
                          );
                        },
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

                    const SizedBox(width: 12), // 좌우 간격

                    // 오른쪽: 수집
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CollectionPage()),
                          );
                        },
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 출석 캘린더 위젯
  Widget _buildCalendar() {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);

    // 이번 주 일요일 구하기
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Column(
      children: [
        // ✅ 상단: 이번달 월만 표시
        Text(
          "${now.month}월",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // ✅ 요일 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text("일"),
            Text("월"),
            Text("화"),
            Text("수"),
            Text("목"),
            Text("금"),
            Text("토"),
          ],
        ),

        const SizedBox(height: 8),

        // 날짜 표시 + 출석 여부
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDates.map((date) {
            final isAttended = date.day == 30 || date.day == 31 || date.day == 1; // ⭐ 조건 예시
            return Column(
              children: [
                Text(
                  "${date.day}",
                  style: TextStyle(fontSize: 14),
                ),
                if (isAttended)
                  const Icon(Icons.star, color: Colors.amber, size: 20)
                else
                  const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}