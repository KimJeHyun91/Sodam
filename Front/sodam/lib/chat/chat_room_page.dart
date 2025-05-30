import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomTitle;
  final List<BluetoothCharacteristic>? writeChars;
  final List<BluetoothCharacteristic>? notifyChars;

  const ChatRoomPage({
    super.key,
    required this.roomTitle,
    this.writeChars,
    this.notifyChars,
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
    _listenToNetwork(); // 아직은 TODO 상태
  }

  void _listenToBLE() async {
    if (widget.notifyChars != null) {
      for (var notifyChar in widget.notifyChars!) {
        try {
          await notifyChar.setNotifyValue(true);
          notifyChar.onValueReceived.listen((data) {
            _addMessage("[BLE] " + String.fromCharCodes(data));
          });
        } catch (e) {
          _addMessage("[오류] BLE 수신 실패: $e");
        }
      }
    }
  }

  void _listenToNetwork() {
    // TODO: Firebase or WebSocket 추가 시 구현
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
    // TODO: 서버 전송 로직 구현
    _addMessage("[나-서버] $text");
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
      appBar: AppBar(title: Text(widget.roomTitle)),
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
