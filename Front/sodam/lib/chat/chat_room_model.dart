import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatRoomModel {
  final String title;
  final List<BluetoothDevice> participants;
  final bool isSecret;
  final String? password;

  ChatRoomModel({
    required this.title,
    required this.participants,
    required this.isSecret,
    this.password,
  });
}
