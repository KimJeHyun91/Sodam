import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../dio_client.dart';
import '../utils/uuid_manager.dart';

class ChatService {
  /// BLE 채팅방 생성
  static Future<int?> createBleChatRoom() async {
    try {
      final creatorId = await UUIDManager.getOrCreateUUID();
      final body = {
        "creatorId": creatorId,
        "roomType": "BLE"
      };

      final res = await DioClient.dio.post("/chat/room", data: body);

      if (res.statusCode == 200) {
        final data = res.data;
        if (data["result"] == 1400 && data.containsKey("roomId")) {
          print("✅ 방 생성 성공, roomId = ${data["roomId"]}");
          return data["roomId"];
        } else {
          print("⚠️ 실패: ${data["message"] ?? '알 수 없음'}");
        }
      } else {
        print("⚠️ HTTP 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ 방 생성 오류: $e");
    }

    return null;
  }

  /// BLE 메시지 서버 동기화
  static Future<void> syncBleMessageToServer({
    required int roomId,
    required String message,
    required String uuid,
    required String senderId,
    required String sentAt,
  }) async {
    final body = {
      "roomId": roomId,
      "senderId": senderId,
      "message": message,
      "uuid": uuid,
      "origin": "bluetooth",
      "sentAt": sentAt,
    };

    try {
      final res = await DioClient.dio.post('/chat/message/sync', data: body);
      if (res.statusCode == 200) {
        print('✅ 메시지 서버 전송 성공');
      } else {
        print('⚠️ 메시지 전송 실패: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ 서버 오류: $e');
    }
  }

  /// 차단 요청 (BlockedUserController 기반)
  static Future<bool> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final res = await DioClient.dio.post(
        "/block",
        queryParameters: {
          "blockerId": blockerId,
          "blockedUserId": blockedUserId,
        },
      );

      if (res.statusCode == 200) {
        print("✅ 차단 성공");
        return true;
      } else {
        print("⚠️ 차단 실패: ${res.data}");
        return false;
      }
    } catch (e) {
      print("❌ 차단 오류: $e");
      return false;
    }
  }

  /// 차단 해제
  static Future<bool> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final res = await DioClient.dio.delete(
        "/block",
        queryParameters: {
          "blockerId": blockerId,
          "blockedUserId": blockedUserId,
        },
      );

      if (res.statusCode == 200) {
        print("✅ 차단 해제 성공");
        return true;
      } else {
        print("⚠️ 차단 해제 실패: ${res.data}");
        return false;
      }
    } catch (e) {
      print("❌ 차단 해제 오류: $e");
      return false;
    }
  }

  /// 차단 여부 조회
  static Future<bool> isBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final res = await DioClient.dio.get(
        "/block/is-blocked",
        queryParameters: {
          "blockerId": blockerId,
          "blockedUserId": blockedUserId,
        },
      );

      if (res.statusCode == 200 && res.data is bool) {
        print("✅ 차단 상태: ${res.data}");
        return res.data;
      } else {
        print("⚠️ 차단 상태 조회 실패: ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ 차단 상태 확인 오류: $e");
      return false;
    }
  }
}
