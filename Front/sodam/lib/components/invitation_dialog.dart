// 📁 lib/widgets/invitation_dialog.dart

import 'package:flutter/material.dart';

class InvitationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDecline();
          },
          child: const Text("거절"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAccept();
          },
          child: const Text("참여"),
        ),
      ],
    );
  }
}
