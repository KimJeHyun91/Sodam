import 'package:dio/dio.dart';
import '../dio_client.dart';

class BlockService {
  // 🔒 차단 등록
  static Future<bool> blockUser(String blockerId, String blockedUserId) async {
    try {
      final res = await DioClient.dio.post(
        '/block',
        queryParameters: {
          'blockerId': blockerId,
          'blockedUserId': blockedUserId,
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('❌ 차단 실패: $e');
      return false;
    }
  }

  // ✅ 차단 해제
  static Future<bool> unblockUser(String blockerId, String blockedUserId) async {
    try {
      final res = await DioClient.dio.delete(
        '/block',
        queryParameters: {
          'blockerId': blockerId,
          'blockedUserId': blockedUserId,
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('❌ 차단 해제 실패: $e');
      return false;
    }
  }

  // 🔍 차단 여부 확인
  static Future<bool> isUserBlocked(String blockerId, String blockedUserId) async {
    try {
      final res = await DioClient.dio.get(
        '/block/is-blocked',
        queryParameters: {
          'blockerId': blockerId,
          'blockedUserId': blockedUserId,
        },
      );
      return res.data == true;
    } catch (e) {
      print('❌ 차단 여부 확인 실패: $e');
      return false;
    }
  }

  // 📋 차단 목록 불러오기
  static Future<List<String>> getBlockedUsers(String blockerId) async {
    try {
      final res = await DioClient.dio.get('/block/$blockerId');
      final data = res.data as List<dynamic>;
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      print('❌ 차단 목록 로딩 실패: $e');
      return [];
    }
  }
}
