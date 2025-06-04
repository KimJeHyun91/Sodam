import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bluetooth_service.dart' as my_ble;
import 'game_board.dart';

class CharacterSelectionPage extends StatefulWidget {
  final List<String> players;
  final String myId;
  final int seed;

  const CharacterSelectionPage({
    super.key,
    required this.players,
    required this.myId,
    required this.seed,
  });

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  int? myOrder;
  int currentTurn = 1;
  bool characterSelected = false;
  CharacterRole? selectedRole;
  final Map<String, CharacterRole> selectedRoles = {};

  final Map<CharacterRole, String> roleLabels = {
    CharacterRole.fisherman: '어부',
    CharacterRole.poet: '시인',
    CharacterRole.playboy: '한량',
    CharacterRole.beauty: '미인',
  };

  final Map<CharacterRole, IconData> roleIcons = {
    CharacterRole.fisherman: Icons.sailing,
    CharacterRole.poet: Icons.menu_book,
    CharacterRole.playboy: Icons.sports_bar,
    CharacterRole.beauty: Icons.face_retouching_natural,
  };

  bool get isHost => widget.myId == widget.players.first;

  @override
  void initState() {
    super.initState();
    calculateTurnOrder();
    listenToMessages();
  }

  void calculateTurnOrder() {
    final shuffled = [...widget.players]..shuffle(Random(widget.seed));
    setState(() {
      myOrder = shuffled.indexOf(widget.myId) + 1;
    });
  }

  void listenToMessages() {
    my_ble.BluetoothService().listenToMessages((message) {
      final parts = message.split(":");
      if (parts.isEmpty) return;

      final type = parts[0];
      final data = parts.length > 1 ? parts[1] : "";

      if (type == "TURN_NEXT") {
        setState(() {
          currentTurn++;
        });
      } else if (type == "SELECTED") {
        final segments = data.split(";");
        final roleStr = segments[0];
        final id = segments.length > 1 ? segments[1].split("=")[1] : "";

        final role = CharacterRole.values.firstWhere(
              (r) => r.name == roleStr,
          orElse: () => CharacterRole.fisherman,
        );

        setState(() {
          selectedRoles[id] = role;
        });

        _checkAllSelected();
      } else if (type == "GAME_START") {
        final sections = data.split("::");
        if (sections.length != 2) return;

        final roleDataStr = sections[0];
        final playersStr = sections[1];
        final players = playersStr.split("|");

        final roleMap = <String, CharacterRole>{};
        final pairs = roleDataStr.split(',');

        for (var pair in pairs) {
          final items = pair.split('=');
          if (items.length == 2) {
            final roleStr = items[0];
            final id = items[1];
            final role = CharacterRole.values.firstWhere(
                  (r) => r.name == roleStr,
              orElse: () => CharacterRole.fisherman,
            );
            roleMap[id] = role;
          }
        }

        selectedRole = roleMap[widget.myId];

        if (selectedRole != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameBoard(
                initialRole: selectedRole!,
                allRoles: roleMap,
              ),
            ),
          );
        }
      }
    });
  }

  void _checkAllSelected() async {
    if (selectedRoles.length == widget.players.length && isHost) {
      await _startCountdownAndStartGame();
    }
  }

  Future<void> _startCountdownAndStartGame() async {
    for (int i = 3; i >= 1; i--) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Center(
            heightFactor: 1.5,
            child: Text(
              '$i',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) Navigator.of(context).pop();
    }

    final roleData = selectedRoles.entries
        .map((e) => '${e.value.name}=${e.key}')
        .join(',');
    final playerListStr = widget.players.join('|');

    for (final playerId in widget.players) {
      await my_ble.BluetoothService()
          .sendMessageTo(playerId, "GAME_START:$roleData::$playerListStr");
      await Future.delayed(const Duration(milliseconds: 100));
    }

    selectedRole = selectedRoles[widget.myId];

    if (mounted && selectedRole != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameBoard(
            initialRole: selectedRole!,
            allRoles: selectedRoles,
          ),
        ),
      );
    }
  }

  void _selectCharacter(CharacterRole role) async {
    if (myOrder != currentTurn || characterSelected) return;

    setState(() {
      characterSelected = true;
      selectedRole = role;
    });

    final message = "SELECTED:${role.name};id=${widget.myId}";
    for (final playerId in widget.players) {
      await my_ble.BluetoothService().sendMessageTo(playerId, message);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    for (final playerId in widget.players) {
      await my_ble.BluetoothService().sendMessageTo(playerId, "TURN_NEXT:");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 선택'),
        actions: [
          if (myOrder != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text('내 순번: ${myOrder}번')),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            currentTurn == myOrder
                ? "당신의 차례입니다. 캐릭터를 선택하세요."
                : "다른 참가자가 선택 중입니다...",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: CharacterRole.values.map((role) {
                final isTaken = selectedRoles.containsValue(role);
                final isMyTurn = myOrder == currentTurn;
                final isEnabled = isMyTurn && !characterSelected && !isTaken;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                    isTaken ? Colors.grey : const Color(0xFFBEE6CE),
                  ),
                  onPressed: isEnabled ? () => _selectCharacter(role) : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(roleIcons[role], size: 48),
                      const SizedBox(height: 12),
                      Text(roleLabels[role]!,
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
