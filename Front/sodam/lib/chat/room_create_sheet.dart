import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../chat/chat_room_model.dart';
import '../services/bluetooth_service.dart' as my_ble;
import 'chat_room_page.dart';

class RoomCreateSheet extends StatefulWidget {
  final List<BluetoothDevice> bleUsers;

  const RoomCreateSheet({super.key, required this.bleUsers});

  @override
  State<RoomCreateSheet> createState() => _RoomCreateSheetState();
}

class _RoomCreateSheetState extends State<RoomCreateSheet> {
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  final Set<BluetoothDevice> _selected = {};
  bool _isSecret = false;

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final room = ChatRoomModel(
      title: _titleController.text,
      participants: _selected.toList(),
      isSecret: _isSecret,
      password: _isSecret ? _passwordController.text : null,
    );

    final writeChars = <BluetoothCharacteristic>[];
    final notifyChars = <BluetoothCharacteristic>[];

    for (final device in _selected) {
      try {
        await device.connect(autoConnect: false);
        final services = await device.discoverServices();

        for (final service in services) {
          for (final char in service.characteristics) {
            if (char.properties.write && !writeChars.contains(char)) {
              writeChars.add(char);
            }
            if (char.properties.notify && !notifyChars.contains(char)) {
              await char.setNotifyValue(true);
              notifyChars.add(char);
              char.lastValueStream.listen((value) {
                final msg = String.fromCharCodes(value);
                print("📩 수신: $msg");
              });
            }
          }
        }
      } catch (e) {
        print("⚠️ 연결 실패: $e");
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            roomTitle: room.title,
            writeChars: writeChars,
            notifyChars: notifyChars,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('방 만들기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            const Text('방 제목'),
            TextField(controller: _titleController),
            const SizedBox(height: 16),
            const Text('근처 BLE 사용자'),
            Expanded(
              child: ListView(
                children: widget.bleUsers.map((device) {
                  final isSelected = _selected.contains(device);
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.bluetooth)),
                    title: Text(device.name.isNotEmpty ? device.name : '(알 수 없음)'),
                    subtitle: Text(device.id.toString()),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selected.add(device);
                          } else {
                            _selected.remove(device);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isSecret,
                  onChanged: (val) => setState(() => _isSecret = val ?? false),
                ),
                const Text('비밀방'),
              ],
            ),
            if (_isSecret)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createRoom,
                child: const Text('방 만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
