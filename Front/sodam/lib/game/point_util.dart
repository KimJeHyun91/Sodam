import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/point_api.dart';
import '../dio_client.dart';

Future<void> giveReward(int amount, {String reasonCode = 'RPS_WIN'}) async {
  print('🎯 [giveReward] 호출됨');

  final prefs = await SharedPreferences.getInstance();
  int? pointNo = prefs.getInt('point_no');

  if (pointNo == null) {
    final id = prefs.getString('loggedInId');
    if (id != null) {
      final newPointNo = await fetchPointNo(id); // 서버에서 다시 가져오기
      if (newPointNo != null) {
        await prefs.setInt('point_no', newPointNo);
        pointNo = newPointNo;
        print('🔁 point_no 재설정 완료: $pointNo');
      } else {
        print('❌ point_no 재설정 실패');
        return;
      }
    } else {
      print('❌ 로그인된 ID 없음');
      return;
    }
  }

  try {
    print('📤 서버로 포인트 지급 요청 전:');
    final response = await DioClient.dio.post(
      '/point/create_history',
      data: {
        'point_no': pointNo,
        'change_amount': amount,
        'point_plus_minus': 'P',
        'point_change_reason_code': 'RPS_WIN',
      },
    );

    print('📥 서버 응답 타입: ${response.data.runtimeType}');
    print('📥 서버 응답 내용: ${response.data}');

    if (response.data == 11) {
      print('✅ $amount 냥 지급 성공');
    } else {
      print('❌ 지급 실패: ${response.data}');
    }
  } catch (e) {
    print('❌ 예외 발생: $e');
  }
}