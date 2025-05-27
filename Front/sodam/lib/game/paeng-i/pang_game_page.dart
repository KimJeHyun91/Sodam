import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpinPowerGamePage extends StatefulWidget {
  final int selectedSpinner;
  const SpinPowerGamePage({super.key, required this.selectedSpinner});

  @override
  State<SpinPowerGamePage> createState() => _SpinPowerGamePageState();
}

class _SpinPowerGamePageState extends State<SpinPowerGamePage>
    with SingleTickerProviderStateMixin {
  static const double RPM_MULTIPLIER = 9.5493;
  static const double SPIN_DECAY = 0.001;
  static const Duration EFFECT_DURATION = Duration(milliseconds: 800);
  static const Duration COUNTDOWN_INTERVAL = Duration(seconds: 1);

  int tapCount = 0;
  double spinSpeed = 0.0;
  double spinAngle = 0.0;
  int timeLeft = 30;
  int countdown = 3;
  double finalScore = 0;
  int lastEffectThreshold = 0;
  String effectText = '';
  bool isGameRunning = false;
  bool isGameOver = false;
  bool showCountdown = false;
  int tapCountPerSecond = 0;

  Timer? gameTimer;
  Timer? countdownTimer;
  Timer? effectTimer;
  Timer? speedMonitorTimer;

  late AnimationController _controller;

  final List<String> spinnerImages = [
    'assets/tiger.png',
    'assets/dragon.png',
    'assets/bird.png',
    'assets/turtle.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    )
      ..addListener(_updateSpinner)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    gameTimer?.cancel();
    countdownTimer?.cancel();
    effectTimer?.cancel();
    speedMonitorTimer?.cancel();
    super.dispose();
  }

  void _updateSpinner() {
    if (!isGameRunning) return;
    setState(() {
      spinAngle = (spinAngle + spinSpeed) % (2 * pi);
      spinSpeed = max(0, spinSpeed - SPIN_DECAY);

      final rpm = spinSpeed * RPM_MULTIPLIER;
      final threshold = rpm ~/ 10;
      if (threshold > lastEffectThreshold) {
        lastEffectThreshold = threshold;
        _triggerEffect('스피드 업!');
      }
    });
  }

  void _triggerEffect(String text) {
    setState(() => effectText = text);
    effectTimer?.cancel();
    effectTimer = Timer(EFFECT_DURATION, () => setState(() => effectText = ''));
  }

  void _resetGameState() {
    setState(() {
      tapCount = 0;
      spinSpeed = 0.0;
      spinAngle = 0.0;
      timeLeft = 30;
      finalScore = 0;
      lastEffectThreshold = 0;
      effectText = '';
      isGameRunning = true;
      isGameOver = false;
      tapCountPerSecond = 0;
    });
  }

  void _startCountdown() {
    setState(() {
      countdown = 3;
      showCountdown = true;
    });
    countdownTimer = Timer.periodic(COUNTDOWN_INTERVAL, (timer) {
      setState(() {
        countdown--;
        if (countdown <= 0) {
          timer.cancel();
          showCountdown = false;
          _startGame();
        }
      });
    });
  }

  void _startGame() {
    _resetGameState();
    _startSpeedMonitor();
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          timer.cancel();
          isGameRunning = false;
          isGameOver = true;
          finalScore = spinSpeed * RPM_MULTIPLIER * tapCount;
          _showGameOverDialog();
        }
      });
    });
  }

  void _startSpeedMonitor() {
    speedMonitorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isGameRunning) return;
      setState(() {
        double increment = 0.08;
        if (tapCountPerSecond >= 5) {
          increment = 0.25;
          _triggerEffect('🔥 스피드 부스트!');
        } else if (tapCountPerSecond >= 3) {
          increment = 0.15;
        } else {
          increment = 0.08;
        }

        spinSpeed += increment;
        tapCountPerSecond = 0;
      });
    });
  }

  void _handleTap() {
    if (!isGameRunning) return;
    setState(() {
      tapCount++;
      tapCountPerSecond++;
    });
  }

  void _showGameOverDialog() {
    final rpm = spinSpeed * RPM_MULTIPLIER;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎯 게임 종료'),
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: finalScore),
          duration: const Duration(seconds: 2),
          builder: (context, value, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('총 탭 수: $tapCount'),
              Text('현재 회전속도: ${rpm.toStringAsFixed(2)} RPM'),
              const SizedBox(height: 10),
              Text('📦 최종 점수: ${value.ceil()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => isGameOver = false);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfo(double rpm) {
    return Positioned(
      top: 40,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('남은 시간: $timeLeft초',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildStatusBox(double rpm) {
    return Positioned(
      top: 100,
      left: 40,
      right: 40,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Column(
          children: [
            Text('현재 회전속도: ${rpm.toStringAsFixed(2)} RPM',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('탭 수: $tapCount',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: spinAngle,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                )
              ],
            ),
            child: Image.asset(
              spinnerImages[widget.selectedSpinner],
              width: 240,
              height: 240,
            ),
          ),
        ),
        if (effectText.isNotEmpty)
          Positioned(
            top: 0,
            child: Text(
              effectText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: isGameRunning ? null : _startCountdown,
        child: const Text('게임 시작'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rpm = spinSpeed * RPM_MULTIPLIER;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/spinnergame_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: GestureDetector(
          onTap: _handleTap,
          child: Stack(
            children: [
              _buildTopInfo(rpm),
              _buildStatusBox(rpm),
              Column(
                children: [
                  const SizedBox(height: 160),
                  Expanded(child: Center(child: _buildSpinner())),
                  _buildStartButton(),
                ],
              ),
              if (showCountdown)
                Center(
                  child: Text('$countdown',
                      style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}