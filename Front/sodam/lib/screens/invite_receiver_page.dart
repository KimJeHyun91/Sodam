// 📁 lib/screens/invite_receiver_page.dart

import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../components/invitation_dialog.dart'; // ✅ 수정된 재사용 가능 다이얼로그

class InviteReceiverPage extends StatefulWidget {
  final BluetoothService bluetoothService;
  final String myId;

  const InviteReceiverPage({
    super.key,
    required this.bluetoothService,
    required this.myId,
  });

  @override
  State<InviteReceiverPage> createState() => _InviteReceiverPageState();
}

class _InviteReceiverPageState extends State<InviteReceiverPage> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _listenForInvite();
  }

  void _listenForInvite() {
    widget.bluetoothService.listenToMessages((String rawMessage) async {
      if (_dialogShown) return;

      final parts = rawMessage.split(':');
      if (parts.length != 2) return;

      final senderId = parts[0];
      final message = parts[1];

      if (message == 'INVITE') {
        _dialogShown = true;

        final accepted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => InvitationDialog(
            title: "게임 초대",
            content: "상대방($senderId)이 당신을 게임에 초대했습니다.\n참여하시겠습니까?",
            onAccept: () => Navigator.of(context).pop(true),
            onDecline: () => Navigator.of(context).pop(false),
          ),
        );

        final response = accepted == true ? 'ACCEPT' : 'DECLINE';
        await widget.bluetoothService.sendMessage("${widget.myId}:$response");

        _dialogShown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("게임 초대 대기 중...")),
    );
  }
}
