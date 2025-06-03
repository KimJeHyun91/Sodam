import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart'; // 경로는 프로젝트 구조에 맞게 수정

Future<void> giveReward(int amount, {String reasonCode = 'RPS_WIN'}) async {
  final prefs = await SharedPreferences.getInstance();
  final pointNo = prefs.getInt('point_no');

  if (pointNo == null) {
    print('❌ point_no가 저장되어 있지 않음');
    return;
  }

  try {
    final response = await DioClient.dio.post(
      '/point/create_history',
      data: {
        'point_no': pointNo,
        'change_amount': amount,
        'point_plus_minus': 'P',
        'point_change_reason_code': reasonCode,
      },
    );

    if (response.data == 11) {
      print('✅ $amount 냥 지급 성공');
    } else {
      print('❌ 지급 실패: ${response.data}');
    }
  } catch (e) {
    print('❌ 지급 중 에러: $e');
  }
}
