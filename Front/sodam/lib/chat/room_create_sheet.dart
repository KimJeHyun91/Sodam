import 'package:flutter/material.dart';
import 'chat_room_model.dart';

class RoomCreateSheet extends StatefulWidget {
  const RoomCreateSheet({super.key});

  @override
  State<RoomCreateSheet> createState() => _RoomCreateSheetState();
}

class _RoomCreateSheetState extends State<RoomCreateSheet> {
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<String> _neighbors = ['김제현', '이하늘'];
  final Set<String> _selected = {};
  bool _isSecret = false;

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            const Text('방만들기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            const Text('방 제목'),
            TextField(controller: _titleController),
            const SizedBox(height: 16),
            const Text('이웃'),
            ..._neighbors.map((name) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name),
                trailing: Checkbox(
                  value: _selected.contains(name),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selected.add(name);
                      } else {
                        _selected.remove(name);
                      }
                    });
                  },
                ),
              );
            }),
            Row(
              children: [
                Checkbox(
                  value: _isSecret,
                  onChanged: (val) => setState(() => _isSecret = val ?? false),
                ),
                const Text('비밀'),
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
                onPressed: () {
                  final newRoom = ChatRoomModel(
                    title: _titleController.text,
                    participants: _selected.toList(),
                    isSecret: _isSecret,
                    password: _isSecret ? _passwordController.text : null,
                  );
                  Navigator.pop(context, newRoom);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9DAB2),
                ),
                child: const Text('만들기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
