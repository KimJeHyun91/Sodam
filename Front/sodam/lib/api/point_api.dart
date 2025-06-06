import 'package:dio/dio.dart';
import '../dio_client.dart';

Future<int?> fetchPointNo(String id) async {
  try {
    final res = await DioClient.dio.get(
      '/point/get_info_id_object',
      queryParameters: {'id': id},
    );

    print('🔍 point 응답 데이터: ${res.data}');
    final data = res.data;

    // 응답이 Map인지 확인 후 처리
    if (data is Map) {
      // 응답이 { "point_no": 3 } 형식인지 먼저 체크
      if (data.containsKey('point_no') && data['point_no'] is int) {
        return data['point_no'];
      }

      // 응답이 { "data": { "point_no": 3 } } 형식인지 체크
      final nested = data['data'];
      if (nested is Map && nested['point_no'] is int) {
        return nested['point_no'];
      }

      print('❌ point_no 없음 또는 타입 오류: ${data}');
      return null;
    } else {
      print('❌ 응답이 Map이 아님: ${data.runtimeType}');
      return null;
    }
  } catch (e) {
    print('point_no 가져오기 중 오류: $e');
    return null;
  }
}
