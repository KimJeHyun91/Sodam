import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/game_invitation_service.dart';
import 'character_selection.dart';

class SelectUserPage extends StatefulWidget {
  final String gameTitle;
  const SelectUserPage({super.key, required this.gameTitle});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  final BluetoothService _btService = BluetoothService();
  late GameInvitationService _invitationService;
  final List<Map<String, dynamic>> _users = [];
  final Set<String> _addedIds = {};
  StreamSubscription? _scanSub;
  String? _myId;
  bool _isWaitingResponses = false;

  @override
  void initState() {
    super.initState();
    _invitationService = GameInvitationService(_btService);
    _invitationService.listenForResponses();
    _setupBluetooth();
  }

  Future<void> _setupBluetooth() async {
    await _btService.initBluetooth();

    _scanSub = _btService.discoveredDevices.listen((devices) {
      for (var device in devices) {
        final id = device.id.id;
        final name = device.name.trim();

        if (name.isEmpty || _addedIds.contains(id)) continue;

        _myId ??= id;
        _addedIds.add(id);
        setState(() {
          _users.add({
            "id": id,
            "name": name,
            "checked": false,
            "avatar": "assets/profile1.png",
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 60), () {
      _btService.stopScanning();
    });
  }

  void _restartScan() async {
    await _btService.stopScanning();
    _addedIds.clear();
    _users.clear();
    setState(() {});
    await _btService.startScanning(force: true); // force 재시작
  }

  void _startInvitationProcess() async {
    final selected = _users.where((u) => u["checked"]).toList();
    if (selected.isEmpty || _myId == null) return;

    final selectedIds = selected.map((u) => u["id"] as String).toList();
    if (!selectedIds.contains(_myId)) selectedIds.insert(0, _myId!);

    setState(() => _isWaitingResponses = true);

    _invitationService.setOnAllAccepted(() {
      setState(() => _isWaitingResponses = false);

      if (selectedIds.length < 2) {
        _showSnackBar("2명 이상 수락해야 게임을 시작할 수 있어요.");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterSelectionPage(
            players: selectedIds,
            myId: _myId!,
            seed: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      );
    });

    _invitationService.setOnRejected((id) {
      setState(() => _isWaitingResponses = false);
      _showSnackBar("🙅 $id 님이 초대를 거절했습니다.");
    });

    await _invitationService.sendInvitations(selectedIds);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _btService.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gameTitle} - 상대 선택'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _restartScan),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("주변 참가자", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: _users.isEmpty
                  ? const Center(child: Text("🔍 BLE 기기 검색 중..."))
                  : ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(user["avatar"]),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(user["id"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: user["checked"],
                          onChanged: (val) {
                            setState(() {
                              _users[index]["checked"] = val!;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_isWaitingResponses)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startInvitationProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8EECF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("게임 시작", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
