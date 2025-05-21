import 'package:flutter/material.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() => _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool notice = true;
  bool vibration = true;
  bool sound = true;
  String selectedSound = "가야금 1";

  final soundOptions = ["가야금 1", "가야금 2", "가야금 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알림"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggleItem("공지", notice, (val) => setState(() => notice = val)),
            _toggleItem("진동", vibration, (val) => setState(() => vibration = val)),
            _toggleItem("소리", sound, (val) => setState(() => sound = val)),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "알림음 (${selectedSound})",
                style: const TextStyle(fontSize: 16, color: Colors.black),  textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            const Text("알림음", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: soundOptions.map((option) {
                  return RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: selectedSound,
                    onChanged: (val) {
                      setState(() {
                        selectedSound = val.toString();
                      });
                    },
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}