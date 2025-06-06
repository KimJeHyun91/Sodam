import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class PointHistoryPage extends StatefulWidget {
  const PointHistoryPage({super.key});

  @override
  State<PointHistoryPage> createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage> {
  List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    fetchPointHistory();
  }

  Future<void> fetchPointHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId') ?? '';
      if (id.isEmpty) return;

      final pointRes = await DioClient.dio.get(
        '/point/get_info_id_object',
        queryParameters: {'id': id},
      );
      final pointNo = pointRes.data['point_no'];

      final historyRes = await DioClient.dio.get(
        '/point/get_history_point_no_list',
        queryParameters: {'id': id}, // ✅ pointNo 아님!
      );

      final List<dynamic> data = historyRes.data;

      setState(() {
        _historyList = data.map<Map<String, dynamic>>((item) => {
          'date': item['created_date'],
          'amount': item['change_amount'],
          'type': item['point_plus_minus'], // 'P' or 'M'
          'reason': item['point_change_reason_code'], // 예: 'BUY', 'attendence'
        }).toList();
      });
    } catch (e) {
      print('❌ 포인트 사용내역 불러오기 실패: $e');
    }
  }

  String _mapReasonCodeToDescription(String code) {
    switch (code) {
      case 'BUY':
        return '상점 물품 구매';
      case 'attendence':
        return '출석 보상';
      case 'REWARD':
        return '미션 보상';
      case 'REFUND':
        return '환불';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("화폐 내역"),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _historyList.isEmpty
          ? const Center(child: Text("사용내역이 없습니다."))
          : ListView.builder(
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final history = _historyList[index];
          final isPlus = history['type'] == 'P';
          final amount = history['amount'];
          final date = DateTime.parse(history['date']);
          final reason = history['reason'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                // 내용 + 금액
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _mapReasonCodeToDescription(reason),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${isPlus ? '+' : '-'}$amount 냥",
                      style: TextStyle(
                        fontSize: 18,
                        color: isPlus ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

