import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBleStore {
  static const _key = 'unsynced_ble_messages';

  /// BLE 메시지 저장
  static Future<void> saveMessage(Map<String, dynamic> msg) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(msg));
    await prefs.setStringList(_key, existing);
  }

  /// 저장된 메시지 전부 로드
  static Future<List<Map<String, dynamic>>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored.map((s) => jsonDecode(s)).cast<Map<String, dynamic>>().toList();
  }

  /// 메시지 전체 삭제
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
