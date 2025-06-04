import 'package:flutter/material.dart';

class InvitationDialog extends StatelessWidget {
  final String senderId;

  // ✅ 콜백 파라미터 추가
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InvitationDialog({
    super.key,
    required this.senderId,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("게임 초대"),
      content: Text("$senderId 님이 게임에 초대했습니다.\n참여하시겠습니까?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onDecline != null) onDecline!(); // ❗ 거절 콜백 호출
          },
          child: const Text("거절"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onAccept != null) onAccept!(); // ❗ 수락 콜백 호출
          },
          child: const Text("참여"),
        ),
      ],
    );
  }
}
