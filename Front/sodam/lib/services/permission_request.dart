// 📁 lib/services/permission_request.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestBluetoothPermissions() async {
  if (Platform.isAndroid) {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.accessMediaLocation,
    ];

    final statuses = await permissions.request();

    if (statuses.values.any((status) => status.isDenied)) {
      print("⚠️ 일부 권한이 거부되었습니다. 기능이 제한될 수 있습니다.");
    } else {
      print("✅ 모든 권한이 허용되었습니다.");
    }
  } else {
    print("✅ Android 이외 플랫폼에서는 권한 요청 생략됨.");
  }
}
