import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../components/invitation_dialog.dart';
import 'character_selection.dart'; // ✅ 캐릭터 선택 페이지 import

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
  bool _navigated = false; // ✅ 중복 이동 방지

  @override
  void initState() {
    super.initState();
    _listenForInviteOrStart();
  }

  void _listenForInviteOrStart() {
    widget.bluetoothService.listenToMessages((String rawMessage) async {
      if (_navigated) return;

      final parts = rawMessage.split(':');
      if (parts.length < 2) return;

      final senderId = parts[0];
      final message = parts.sublist(1).join(':');

      // ✅ 초대 수신
      if (message == 'INVITE' && !_dialogShown) {
        _dialogShown = true;

        final result = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => InvitationDialog(senderId: senderId),
        );

        if (result == 'accept') {
          await widget.bluetoothService.sendMessageTo(senderId, "$senderId:ACCEPT");
        } else {
          await widget.bluetoothService.sendMessageTo(senderId, "$senderId:DECLINE");
        }

        _dialogShown = false;
      }

      // ✅ START 메시지 수신 형식: HOST:START:<seed>:<player1>,<player2>,...
      else if (senderId == 'HOST' && message.startsWith('START:')) {
        final startParts = message.split(':');
        if (startParts.length != 3) return;

        final seed = int.tryParse(startParts[1]);
        if (seed == null) return;

        final playerList = startParts[2].split(',');

        _navigated = true;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterSelectionPage(
              players: playerList,
              myId: widget.myId,
              seed: seed,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "⏳ 상대방 초대 메시지 수신 대기 중...",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
