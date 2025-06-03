import 'package:dio/dio.dart';
import '../dio_client.dart';

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