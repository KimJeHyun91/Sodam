import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../chat/chat_service.dart';
import '../utils/uuid_manager.dart';


class ChatRoomPage extends StatefulWidget {
  final String roomTitle;
  final List<BluetoothCharacteristic>? writeChars;
  final List<BluetoothCharacteristic>? notifyChars;
  final int? roomId;
  final String? targetUserId; // 차단 대상자 UUID


  const ChatRoomPage({
    super.key,
    required this.roomTitle,
    this.writeChars,
    this.notifyChars,
    this.roomId,
    this.targetUserId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenToBLE();
  }

  void _listenToBLE() async {
    if (widget.notifyChars != null) {
      for (var notifyChar in widget.notifyChars!) {
        try {
          await notifyChar.setNotifyValue(true);
          notifyChar.onValueReceived.listen((data) {
            _addMessage("[BLE] ${String.fromCharCodes(data)}");
          });
        } catch (e) {
          _addMessage("[오류] BLE 수신 실패: $e");
        }
      }
    }
  }

  void _addMessage(String msg) {
    setState(() {
      messages.add(msg);
    });
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    if (widget.writeChars != null) {
      for (var writeChar in widget.writeChars!) {
        try {
          await writeChar.write(text.codeUnits);
        } catch (e) {
          _addMessage("[오류] BLE 전송 실패: $e");
        }
      }
      _addMessage("[나-BLE] $text");
    }

    await _sendOverNetwork(text);
    controller.clear();
  }

  Future<void> _sendOverNetwork(String text) async {
    if (widget.roomId != null) {
      final senderId = await UUIDManager.getOrCreateUUID();
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      await ChatService.syncBleMessageToServer(
        roomId: widget.roomId!,
        message: text,
        uuid: uuid,
        senderId: senderId,
        sentAt: DateTime.now().toIso8601String(),
      );
      _addMessage("[나-서버] $text");
    } else {
      _addMessage("[오류] roomId 없음 - 서버 전송 실패");
    }
  }

  Future<void> _blockUser() async {
    if (widget.targetUserId == null) {
      _addMessage("⚠️ 차단 대상이 없습니다.");
      return;
    }

    final blockerId = await UUIDManager.getOrCreateUUID();

    final result = await ChatService.blockUser(
      blockerId: blockerId,
      blockedUserId: widget.targetUserId!,
    );

    if (result) {
      _addMessage("🚫 상대방을 차단했습니다.");
    } else {
      _addMessage("⚠️ 차단 실패");
    }
  }

  Future<void> _unblockUser() async {
    if (widget.targetUserId == null) {
      _addMessage("⚠️ 차단 대상이 없습니다.");
      return;
    }

    final blockerId = await UUIDManager.getOrCreateUUID();

    final result = await ChatService.unblockUser(
      blockerId: blockerId,
      blockedUserId: widget.targetUserId!,
    );

    if (result) {
      _addMessage("✅ 차단 해제했습니다.");
    } else {
      _addMessage("⚠️ 차단 해제 실패");
    }
  }

  void _showBlockDialog() async {
    if (widget.targetUserId == null) {
      _addMessage("⚠️ 차단 대상이 없습니다.");
      return;
    }

    final blockerId = await UUIDManager.getOrCreateUUID();
    final isBlocked = await ChatService.isBlocked(
      blockerId: blockerId,
      blockedUserId: widget.targetUserId!,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("차단/해제"),
          content: Text("이 사용자에 대해 어떤 작업을 수행하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            if (!isBlocked)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _blockUser();
                },
                child: Text("차단", style: TextStyle(color: Colors.red)),
              ),
            if (isBlocked)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _unblockUser();
                },
                child: Text("차단 해제"),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.notifyChars != null) {
      for (var notifyChar in widget.notifyChars!) {
        notifyChar.setNotifyValue(false);
      }
    }
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.block),
            onPressed: _showBlockDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: messages[index].contains("나")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: messages[index].contains("나")
                          ? Colors.lightBlueAccent.withOpacity(0.4)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(messages[index]),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}