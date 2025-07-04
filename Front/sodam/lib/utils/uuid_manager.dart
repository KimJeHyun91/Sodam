import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UUIDManager {
  static const _uuidKey = 'device_uuid';
  static const _nicknameKey = 'device_nickname';

  static Future<String> getOrCreateUUID() async {
    final prefs = await SharedPreferences.getInstance();
    var uuid = prefs.getString(_uuidKey);
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_uuidKey, uuid);
    }
    return uuid;
  }

  static Future<String> getOrCreateNickname() async {
    final prefs = await SharedPreferences.getInstance();
    var nickname = prefs.getString(_nicknameKey);
    if (nickname == null) {
      nickname = '이웃_' + DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      await prefs.setString(_nicknameKey, nickname);
    }
    return nickname;
  }

  static Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
  }

  static Future<String?> getUUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uuidKey);
  }

  static Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nicknameKey);
  }
}