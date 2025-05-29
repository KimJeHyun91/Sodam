import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String roomTitle;

  const ChatRoomPage({super.key, required this.roomTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('$roomTitle 단톡방'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: 참여자 추가 기능
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ChatBubble(isMe: false, message: '안녕!'),
                _ChatBubble(isMe: true, message: '안녕하세요!'),
                _ChatBubble(isMe: true, message: '', isImage: true),
              ],
            ),
          ),
          const _ChatInputField(),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final bool isImage;

  const _ChatBubble({
    required this.isMe,
    required this.message,
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? Colors.lightBlue.shade200 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isImage
                ? Container(
              width: 100,
              height: 80,
              color: Colors.blue[100],
            )
                : Text(message),
          ),
        ],
      ),
    );
  }
}

class _ChatInputField extends StatelessWidget {
  const _ChatInputField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '메시지 입력',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // TODO: 메시지 전송 로직
            },
          )
        ],
      ),
    );
  }
}