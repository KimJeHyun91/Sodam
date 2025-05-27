import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TtagjiGamePage extends StatefulWidget {
  const TtagjiGamePage({super.key});

  @override
  State<TtagjiGamePage> createState() => _TtagjiGamePageState();
}

class _TtagjiGamePageState extends State<TtagjiGamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _gaugeValue = 0.0;
  bool _isPlaying = false;
  String _result = '';

  int _playerAScore = 0;
  int _playerBScore = 0;
  int _turnTimeLeft = 10;
  Timer? _turnTimer;
  int _currentPlayer = 0; // 0: A, 1: B

  double _successStart = 0.0;
  double _successEnd = 0.0;
  double _greatStart = 0.0;
  double _greatEnd = 0.0;

  void _setRandomSuccessZone() {
    final random = Random();
    _successStart = random.nextDouble() * 0.4 + 0.1;
    _successEnd = _successStart + 0.3;
    double center = (_successStart + _successEnd) / 2;
    _greatStart = center - 0.025;
    _greatEnd = center + 0.025;
  }

  void _startTurn() {
    setState(() {
      _setRandomSuccessZone();
      _result = '';
      _turnTimeLeft = 10;
      _isPlaying = false; // 일단 false로 두고 나중에 true로 바꿈
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isPlaying = true;
      });
      _controller.repeat(reverse: true);

      _turnTimer?.cancel();
      _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _turnTimeLeft--;
          if (_turnTimeLeft <= 0) {
            _handleThrow(auto: true);
          }
        });
      });
    });
  }

  void _handleThrow({bool auto = false}) {
    if (!_isPlaying) return;

    String judgeResult = '';
    bool isFlipped = false;

    if (_gaugeValue >= _greatStart && _gaugeValue <= _greatEnd) {
      judgeResult = '🎯 대성공';
      isFlipped = true;
    } else if (_gaugeValue >= _successStart && _gaugeValue <= _successEnd) {
      judgeResult = '성공';
      isFlipped = Random().nextDouble() < 0.65;
    } else {
      judgeResult = '실패';
      final center = (_successStart + _successEnd) / 2;
      final distance = (_gaugeValue - center).abs();
      final chance = max(0, 0.15 - distance);
      isFlipped = Random().nextDouble() < chance;
    }

    if (isFlipped) {
      if (_currentPlayer == 0) _playerAScore++;
      else _playerBScore++;
    }

    _controller.stop();
    _turnTimer?.cancel();

    setState(() {
      _result =
      '[플레이어 ${_currentPlayer == 0 ? 'A' : 'B'}] $judgeResult! ${isFlipped ? '딱지가 뒤집어졌습니다!' : '딱지가 안 뒤집어졌습니다.'}';
      _isPlaying = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_playerAScore >= 5 || _playerBScore >= 5) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('게임 종료'),
            content: Text('승자: ${_playerAScore >= 5 ? '플레이어 A' : '플레이어 B'}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _playerAScore = 0;
                    _playerBScore = 0;
                    _result = '';
                    _currentPlayer = 0;
                  });
                  _startTurn();
                },
                child: const Text('다시 시작'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _currentPlayer = (_currentPlayer + 1) % 2;
        _setRandomSuccessZone();
      });
      Future.delayed(const Duration(milliseconds: 300), _startTurn);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      setState(() {
        _gaugeValue = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _turnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('딱지치기 턴제 게임'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('플레이어 A: $_playerAScore점', style: const TextStyle(fontSize: 16)),
                Text('플레이어 B: $_playerBScore점', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('남은 턴 시간: $_turnTimeLeft초', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 턴: 플레이어 ${_currentPlayer == 0 ? 'A' : 'B'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomPaint(
                  size: const Size(200, 100),
                  painter: ArcGaugePainter(
                    value: _gaugeValue,
                    successStart: _successStart,
                    successEnd: _successEnd,
                    greatStart: _greatStart,
                    greatEnd: _greatEnd,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isPlaying ? _handleThrow : _startTurn,
                  child: Text(_isPlaying ? '딱지 던지기!' : '게임 시작'),
                ),
                const SizedBox(height: 20),
                Text(_result, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArcGaugePainter extends CustomPainter {
  final double value;
  final double successStart;
  final double successEnd;
  final double greatStart;
  final double greatEnd;

  ArcGaugePainter({
    required this.value,
    required this.successStart,
    required this.successEnd,
    required this.greatStart,
    required this.greatEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final failPaint1 = Paint()
      ..color = Colors.deepOrangeAccent.withOpacity(0.6)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, pi, pi * (successStart - 0.0), false, failPaint1);

    final successPaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, pi + pi * successStart, pi * (successEnd - successStart), false, successPaint);

    final greatPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, pi + pi * greatStart, pi * (greatEnd - greatStart), false, greatPaint);

    final failPaint2 = Paint()
      ..color = Colors.deepOrangeAccent.withOpacity(0.6)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, pi + pi * successEnd, pi * (1.0 - successEnd), false, failPaint2);

    final pointerPaint = Paint()
      ..color = Colors.black;
    final pointerAngle = pi + pi * value;
    final pointerLength = radius + 10;
    final tip = Offset(center.dx + pointerLength * cos(pointerAngle), center.dy + pointerLength * sin(pointerAngle));
    final left = Offset(center.dx + (radius - 10) * cos(pointerAngle - 0.05), center.dy + (radius - 10) * sin(pointerAngle - 0.05));
    final right = Offset(center.dx + (radius - 10) * cos(pointerAngle + 0.05), center.dy + (radius - 10) * sin(pointerAngle + 0.05));

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
