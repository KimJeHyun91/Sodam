import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/game_invitation_service.dart';
import 'character_selection.dart';
import '../components/invitation_dialog.dart';

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
  final Set<String> _connectedIds = {}; // ✅ 연결된 기기 ID 저장

  StreamSubscription? _scanSub;
  String? _myId;
  bool _isWaitingResponses = false;

  @override
  void initState() {
    super.initState();

    _invitationService = GameInvitationService(_btService);
    _invitationService.setOnAllAccepted(_goToCharacterPage);
    _invitationService.setOnRejected((id) {
      setState(() => _isWaitingResponses = false);
      _showSnackBar("🙅 $id 님이 초대를 거절했습니다.");
    });

    _setupBluetooth();

    _invitationService.onMessage.listen((message) {
      if (message.contains("INVITE_FROM")) {
        final senderId = message.split(":")[1];
        showDialog(
          context: context,
          builder: (_) => InvitationDialog(
            senderId: senderId,
            onAccept: () => _btService.sendMessageTo(senderId, "$senderId:ACCEPT"),
            onDecline: () => _btService.sendMessageTo(senderId, "$senderId:DECLINE"),
          ),
        );
      }
    });
  }

  Future<void> _setupBluetooth() async {
    await _btService.initBluetooth();

    _scanSub = _btService.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;
        final id = device.remoteId.str;
        final name = device.platformName.trim();

        if (name.isEmpty || _addedIds.contains(id)) continue;

        // ✅ 이어폰, TV 필터링
        final lowered = name.toLowerCase();
        if (lowered.contains("buds") || lowered.contains("tv") || lowered.contains("bose") || lowered.contains("galaxy watch") || lowered.contains("le-")) {
          continue;
        }

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
      _btService.stopAll();
    });
  }

  void _restartScan() async {
    _btService.stopAll();
    _addedIds.clear();
    _connectedIds.clear();
    _users.clear();
    setState(() {});
    await _btService.startScanning();
  }

  void _connectSelectedUsers() async {
    final selected = _users.where((u) => u["checked"]).toList();
    if (selected.isEmpty) return;

    for (var user in selected) {
      final id = user["id"];
      try {
        final connected = await _btService.connectToDeviceById(id);
        if (connected) {
          _connectedIds.add(id);
          _showSnackBar("✅ $id 연결 성공");
        } else {
          _showSnackBar("❌ $id 연결 실패");
        }
      } catch (e) {
        _showSnackBar("⚠️ $id 연결 오류: $e");
      }
    }

    setState(() {});
  }

  void _startInvitationProcess() async {
    if (_connectedIds.isEmpty || _myId == null) {
      _showSnackBar("❌ 먼저 연결 후 게임을 시작하세요");
      return;
    }

    final selectedIds = _connectedIds.toList();
    if (!selectedIds.contains(_myId)) selectedIds.insert(0, _myId!);

    setState(() => _isWaitingResponses = true);
    await _invitationService.sendInvitations(selectedIds);
  }

  void _goToCharacterPage() {
    setState(() => _isWaitingResponses = false);
    final ids = _connectedIds.toList();
    if (!ids.contains(_myId)) ids.insert(0, _myId!);

    final seed = DateTime.now().millisecondsSinceEpoch;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterSelectionPage(
          players: ids,
          myId: _myId!,
          seed: seed,
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _btService.stopAll();
    _invitationService.dispose();
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
                  final isConnected = _connectedIds.contains(user["id"]);
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
                              Text(
                                isConnected ? "✅ 연결됨" : "⛔ 미연결",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isConnected ? Colors.green : Colors.red,
                                ),
                              ),
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
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _connectSelectedUsers,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("🔗 연결하기", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startInvitationProcess,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("🎮 게임 시작", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
