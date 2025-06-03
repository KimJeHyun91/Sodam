import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart'; // DioClient 경로 맞춰서 import

Future<int?> fetchPointNo(String userId) async {
  try {
    final response = await DioClient.dio.get(
      '/point/get_info_id_object',
      queryParameters: {'id': userId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      return data['point_no']; // 엽전 번호 반환
    } else {
      print('point_no 가져오기 실패: 응답 없음');
    }
  } catch (e) {
    print('point_no 가져오기 중 오류: $e');
  }
  return null;
}

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
        'point_change_reason_code': reasonCode, // 기본값은 가위바위보
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

