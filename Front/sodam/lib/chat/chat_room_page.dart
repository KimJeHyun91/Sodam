import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../chat/chat_service.dart';
import '../utils/uuid_manager.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomTitle;
  final List<BluetoothCharacteristic>? writeChars;
  final List<BluetoothCharacteristic>? notifyChars;
  final int? roomId;
  final String? targetUserId;

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
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _initBlockState();
    _listenToBLE();
  }

  void _initBlockState() async {
    if (widget.targetUserId != null) {
      final myId = await UUIDManager.getOrCreateUUID();
      final result = await ChatService.isBlocked(
        blockerId: myId,
        blockedUserId: widget.targetUserId!,
      );
      setState(() {
        isBlocked = result;
      });
    }
  }

  void _listenToBLE() async {
    if (widget.notifyChars != null) {
      for (var char in widget.notifyChars!) {
        try {
          await char.setNotifyValue(true);
          char.onValueReceived.listen((data) {
            final msg = String.fromCharCodes(data);
            if (!isBlocked) {
              _addMessage("[BLE] $msg");
            }
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
    if (text.isEmpty || isBlocked) return;

    // BLE 전송
    if (widget.writeChars != null) {
      for (var char in widget.writeChars!) {
        try {
          await char.write(text.codeUnits);
        } catch (e) {
          _addMessage("[오류] BLE 전송 실패: $e");
        }
      }
      _addMessage("[나-BLE] $text");
    }

    // 서버 전송
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
    final myId = await UUIDManager.getOrCreateUUID();
    if (widget.targetUserId == null) return;

    final result = await ChatService.blockUser(
      blockerId: myId,
      blockedUserId: widget.targetUserId!,
    );

    if (result) {
      setState(() {
        isBlocked = true;
        _addMessage("🚫 상대방을 차단했습니다.");
      });
    } else {
      _addMessage("⚠️ 차단 실패");
    }
  }

  Future<void> _unblockUser() async {
    final myId = await UUIDManager.getOrCreateUUID();
    if (widget.targetUserId == null) return;

    final result = await ChatService.unblockUser(
      blockerId: myId,
      blockedUserId: widget.targetUserId!,
    );

    if (result) {
      setState(() {
        isBlocked = false;
        _addMessage("✅ 차단 해제했습니다.");
      });
    } else {
      _addMessage("⚠️ 차단 해제 실패");
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("차단 설정"),
        content: const Text("이 사용자에 대해 어떤 작업을 수행하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          if (!isBlocked)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _blockUser();
              },
              child: const Text("차단", style: TextStyle(color: Colors.red)),
            ),
          if (isBlocked)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _unblockUser();
              },
              child: const Text("차단 해제"),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var c in widget.notifyChars ?? []) {
      c.setNotifyValue(false);
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
          if (widget.targetUserId != null)
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
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.startsWith("[나");

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.lightBlue.withOpacity(0.3) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg),
                  ),
                );
              },
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
                    enabled: !isBlocked,
                    decoration: InputDecoration(
                      hintText: isBlocked ? "차단된 사용자입니다" : "메시지를 입력하세요",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isBlocked ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
