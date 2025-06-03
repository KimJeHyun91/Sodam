// 📁 screens/game_board.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

class GameBoard extends StatefulWidget {
  final CharacterRole initialRole;
  final Map<String, CharacterRole> allRoles;
  const GameBoard({super.key, required this.initialRole, required this.allRoles});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  final int boardSize = 72;
  final int rows = 8;
  final int cols = 9;

  late List<Player> players;
  int currentPlayerIndex = 0;
  int yutResult = 1;
  String yutName = '도';
  bool isRolling = false;
  bool showGlow = false;

  late AnimationController _animController;
  late Animation<double> _rotationAnim;
  late List<BoardCell> board;
  late List<int> spiralOrder;

  final Map<CellColorType, List<CharacterRole>> advantages = {
    CellColorType.sky: [CharacterRole.fisherman],
    CellColorType.yellow: [CharacterRole.poet],
    CellColorType.black: [CharacterRole.playboy],
    CellColorType.pink: [CharacterRole.beauty],
  };

  final Map<CellColorType, List<CharacterRole>> penalties = {
    CellColorType.yellow: [CharacterRole.fisherman],
    CellColorType.black: [CharacterRole.poet],
    CellColorType.pink: [CharacterRole.playboy],
    CellColorType.sky: [CharacterRole.beauty],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _rotationAnim = Tween<double>(begin: 0, end: 2 * pi).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reset();
        setState(() => isRolling = false);
      }
    });
    spiralOrder = generateSpiralOrder(rows, cols);
    board = generateColoredBoard(boardSize);
    assignLadders();
    assignTeleporters();

    players = widget.allRoles.entries.map((e) => Player(name: getRoleName(e.value), role: e.value)).toList();
  }

  String getRoleName(CharacterRole role) {
    switch (role) {
      case CharacterRole.fisherman:
        return '어부';
      case CharacterRole.poet:
        return '시인';
      case CharacterRole.playboy:
        return '한량';
      case CharacterRole.beauty:
        return '미인';
    }
  }
  void assignLadders() {
    final random = Random();
    List<List<int>> ranges = [
      [9, 16, 37, 42],
      [17, 23, 43, 48],
      [25, 30, 49, 52],
    ];

    for (var range in ranges) {
      int from = range[0] + random.nextInt(range[1] - range[0] + 1);
      int to = range[2] + random.nextInt(range[3] - range[2] + 1);
      board[from - 1].isLadder = true;
      board[from - 1].ladderTarget = to;
    }
  }

  void assignTeleporters() {
    final random = Random();
    List<int> invalid = board.where((b) => b.isLadder).map((b) => b.number).toList();

    List<int> candidates = List.generate(boardSize - 20, (i) => i + 1)
        .where((n) => !invalid.contains(n) && !invalid.contains(n + 20))
        .toList();

    candidates.shuffle();
    int source = candidates.first;
    int target = source >= 36 ? source - 20 : source + 20;

    board[source - 1].isTeleport = true;
    board[source - 1].teleportTarget = target;
    board[target - 1].isTeleport = true;
    board[target - 1].teleportTarget = source;
  }

  List<BoardCell> generateColoredBoard(int size) {
    final random = Random();
    List<CellColorType> baseColors = [CellColorType.sky, CellColorType.black, CellColorType.pink, CellColorType.yellow];
    List<int> colorIndices = List.generate(size - 5, (i) => i + 4)..shuffle();

    Map<CellColorType, int> colorCount = { for (var c in baseColors) c: 0 };
    List<CellColorType> finalColors = List.generate(size, (i) => CellColorType.white);

    for (var idx in colorIndices) {
      for (var c in baseColors) {
        if (colorCount[c]! < 7) {
          finalColors[idx] = c;
          colorCount[c] = colorCount[c]! + 1;
          break;
        }
      }
      if (colorCount.values.every((v) => v >= 7)) break;
    }

    return List.generate(size, (i) => BoardCell(number: i + 1, color: finalColors[i]));
  }

  List<int> generateSpiralOrder(int rows, int cols) {
    List<List<int>> grid = List.generate(rows, (_) => List.filled(cols, 0));
    int num = 1, top = 0, bottom = rows - 1, left = 0, right = cols - 1;
    while (top <= bottom && left <= right) {
      for (int i = left; i <= right; i++) grid[top][i] = num++;
      top++;
      for (int i = top; i <= bottom; i++) grid[i][right] = num++;
      right--;
      if (top <= bottom) for (int i = right; i >= left; i--) grid[bottom][i] = num++;
      bottom--;
      if (left <= right) for (int i = bottom; i >= top; i--) grid[i][left] = num++;
      left++;
    }
    return grid.expand((row) => row).toList();
  }

  void rollYut() {
    if (isRolling) return;
    setState(() => isRolling = true);
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
      final rand = Random();
      List<bool> sticks = List.generate(4, (_) => rand.nextBool());
      int flatCount = sticks.where((e) => e).length;
      int result = (flatCount == 0) ? 5 : flatCount;
      String name = ['도', '개', '걸', '윷', '모'][result - 1];

      Player currentPlayer = players[currentPlayerIndex];
      if (currentPlayer.isFinished) {
        setState(() => isRolling = false);
        return;
      }

      int newPos = (currentPlayer.position + result).clamp(1, boardSize);
      BoardCell cell = board[newPos - 1];

      if (cell.isTeleport && cell.teleportTarget != null) {
        _showEffectDialog('🔁 텔레포트!', '${newPos} → ${cell.teleportTarget}번 칸으로 이동!');
        newPos = cell.teleportTarget!;
      }

      if (cell.isLadder && cell.ladderTarget != null) {
        _showEffectDialog('📈 사다리!', '${newPos} → ${cell.ladderTarget}번 칸으로 이동!');
        newPos = cell.ladderTarget!;
      }

      setState(() {
        yutResult = result;
        yutName = name;
        currentPlayer.position = newPos;

        handleCellEffect(currentPlayer);

        if (newPos == boardSize) {
          currentPlayer.isFinished = true;
          _showFinishDialog(currentPlayer.name);
        }
        bool allFinished = players.every((p) => p.isFinished);

        if (allFinished) {
          List<Player> ranking = [...players];
          ranking.sort((a, b) => b.position.compareTo(a.position));
          _showFinalRankingDialog(ranking);
        }
        showGlow = (result == 4 || result == 5);
        if (showGlow) {
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() => showGlow = false);
          });
        }

        if (!(result == 4 || result == 5)) {
          do {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
          } while (players[currentPlayerIndex].isFinished);
        }
      });
    });
  }

  void handleCellEffect(Player player) {
    final cell = board[player.position - 1];
    final color = cell.color;
    final role = player.role;

    if (player.position == boardSize) return;

    if (advantages[color]?.contains(role) == true) {
      _showEffectDialog('🎉 혜택!', '2칸 전진!');
      player.position = (player.position + 2).clamp(1, boardSize);
    } else if (penalties[color]?.contains(role) == true) {
      _showEffectDialog('⚠️ 벌칙!', '2칸 후퇴!');
      player.position = (player.position - 2).clamp(1, boardSize);
    }
  }

  void _showEffectDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인"))],
      ),
    );
  }

  void _showFinishDialog(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 도착!"),
        content: Text('$name님이 중앙에 도착했습니다!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인"))],
      ),
    );
  }

  void _showFinalRankingDialog(List<Player> ranking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🏁 최종 순위"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ranking.asMap().entries.map((entry) {
            int idx = entry.key + 1;
            Player p = entry.value;
            return Text('$idx등 - ${p.name} (${p.position}번)');
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인")),
        ],
      ),
    );
  }

  Color getCellColor(CellColorType color) {
    return {
      CellColorType.sky: Colors.lightBlueAccent,
      CellColorType.white: Colors.white,
      CellColorType.black: Colors.grey.shade700,
      CellColorType.pink: Colors.pink.shade200,
      CellColorType.yellow: Colors.amber.shade100,
    }[color]!;
  }

  Widget buildYutImage(int result) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _rotationAnim,
            child: Image.asset('assets/yut_$result.png', width: 100, height: 100),
          ),
          if (showGlow)
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.yellow.withOpacity(0.8), Colors.transparent],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('남승도 보드게임')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  itemCount: boardSize,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                  itemBuilder: (context, index) {
                    int number = spiralOrder[index];
                    BoardCell cell = board[number - 1];
                    List<Widget> playerIcons = players
                        .where((p) => p.position == number)
                        .map((p) => Icon(Icons.person, color: Colors.primaries[players.indexOf(p)], size: 16))
                        .toList();
                    return Container(
                      margin: const EdgeInsets.all(1),
                      color: getCellColor(cell.color),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text('$number', style: const TextStyle(fontSize: 12)),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Wrap(children: playerIcons),
                          ),
                          if (cell.isTeleport)
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.swap_horiz, size: 16, color: Colors.deepPurple),
                            ),
                          if (cell.isLadder)
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Icon(Icons.stairs, size: 16, color: Colors.green),
                            ),
                          if (board.any((b) => b.ladderTarget == number))
                            const Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.flag, size: 16, color: Colors.red),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('🎲 윤목 결과: $yutName', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                buildYutImage(yutResult),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: rollYut,
                  child: Text('${players[currentPlayerIndex].name}의 턴 - 윤목 던지기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}