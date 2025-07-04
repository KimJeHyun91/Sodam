import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiseokGamePage extends StatefulWidget {
  const BiseokGamePage({super.key});

  @override
  State<BiseokGamePage> createState() => _BiseokGamePageState();
}

class _BiseokGamePageState extends State<BiseokGamePage> {
  static const double gravity = 0.5;
  static const double powerStep = 0.02;
  static const double maxPower = 1.0;
  static const double minPower = 0.1;

  double stonePosX = 100;
  double stonePosY = 0;
  double velocityX = 0;
  double velocityY = 0;
  double launchAngle = 45;
  double groundY = 0;

  double biseokX = 300;
  double biseokY = 400;
  double windForce = 0.0;

  double launchPower = 0.1;
  bool isPowerIncreasing = true;
  bool isStoneFlying = false;
  bool isGameOver = false;
  bool isHitEffectVisible = false;
  bool stoneVisible = true;

  int score = 0;
  int timeLeft = 60;
  int consecutiveHits = 0;

  Timer? powerGaugeTimer;
  Timer? stoneMotionTimer;
  Timer? countdownTimer;

  static const double stoneSize = 20;
  static const double targetWidth = 40;
  static const double targetHeight = 60;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    startCountdownTimer();
    startPowerGaugeAnimation();
  }

  void startCountdownTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft == 0) {
          isGameOver = true;
          timer.cancel();
          stoneMotionTimer?.cancel();
          powerGaugeTimer?.cancel();
        }
      });
    });
  }

  void startPowerGaugeAnimation() {
    powerGaugeTimer?.cancel();
    powerGaugeTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      setState(() {
        launchPower += isPowerIncreasing ? powerStep : -powerStep;
        if (launchPower >= maxPower) {
          launchPower = maxPower;
          isPowerIncreasing = false;
        } else if (launchPower <= minPower) {
          launchPower = minPower;
          isPowerIncreasing = true;
        }
      });
    });
  }

  void resetStonePosition() {
    stonePosY = groundY;
  }

  void spawnRandomBiseok() {
    final screenWidth = MediaQuery.of(context).size.width;
    final minX = screenWidth * 0.4;
    final maxX = screenWidth * 0.95;
    final forbiddenZoneStart = screenWidth * 0.85;

    final minY = groundY - 250;
    final maxY = groundY - 30;

    double randomX;
    do {
      randomX = minX + Random().nextDouble() * (maxX - minX);
    } while (randomX >= forbiddenZoneStart);

    setState(() {
      biseokX = randomX;
      biseokY = minY + Random().nextDouble() * (maxY - minY);
      // ✅ 서풍은 약하게
      windForce = Random().nextDouble();
      windForce = Random().nextBool() ? windForce * 1.0 : windForce * -0.3;
    });
  }

  void launchStone() {
    if (isGameOver || isStoneFlying || !stoneVisible) return;

    setState(() {
      isStoneFlying = true;
      isHitEffectVisible = false;
      stoneVisible = true;
    });

    powerGaugeTimer?.cancel();

    final rad = launchAngle * pi / 180;
    velocityX = cos(rad) * launchPower * 30 + windForce * 3;
    velocityY = -sin(rad) * launchPower * 30;

    stoneMotionTimer?.cancel();
    stoneMotionTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      updateStonePosition();
    });
  }

  void updateStonePosition() {
    setState(() {
      stonePosX += velocityX;
      stonePosY += velocityY;
      velocityY += gravity;

      final stoneRect = Rect.fromLTWH(stonePosX, stonePosY, stoneSize, stoneSize);
      final biseokRect = Rect.fromLTWH(biseokX, biseokY, targetWidth, targetHeight);

      if (!isHitEffectVisible && stoneRect.overlaps(biseokRect)) {
        // ✅ 점수: 기본 2점, 연속 2회 이상 3점
        consecutiveHits++;
        score += consecutiveHits >= 2 ? 3 : 2;
        isHitEffectVisible = true;
        stoneVisible = false;
        stoneMotionTimer?.cancel();
        prepareNextRound();
      } else if (!isHitEffectVisible && stonePosY >= groundY) {
        // 실패 시 연속 히트 초기화
        consecutiveHits = 0;
        resetStonePosition();
        velocityX = 0;
        velocityY = 0;
        stoneVisible = false;
        stoneMotionTimer?.cancel();
        prepareNextRound();
      }
    });
  }

  void prepareNextRound() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isStoneFlying = false;
      });
      if (!isGameOver) {
        Future.delayed(const Duration(milliseconds: 400), () {
          setState(() {
            stonePosX = 100;
            resetStonePosition();
            isHitEffectVisible = false;
            stoneVisible = true;
          });
          spawnRandomBiseok();
          startPowerGaugeAnimation();
        });
      }
    });
  }

  String getFormattedWindLabel() {
    if (windForce.abs() < 0.1) return '무풍';
    return windForce > 0 ? '→ 동풍' : '← 서풍';
  }

  void updateLaunchAngle(Offset localPosition) {
    final dx = localPosition.dx - 100;
    final dy = groundY - localPosition.dy;
    final newAngle = atan2(dy, dx) * 180 / pi;
    if (newAngle >= 0 && newAngle <= 90) {
      setState(() {
        launchAngle = newAngle;
      });
    }
  }

  @override
  void dispose() {
    stoneMotionTimer?.cancel();
    countdownTimer?.cancel();
    powerGaugeTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          final newGroundY = MediaQuery.of(context).size.height - 50;
          if (groundY != newGroundY) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                groundY = newGroundY;
                stonePosY = groundY;
                resetStonePosition();
                spawnRandomBiseok();
              });
            });
          }
        }

        return Scaffold(
          body: GestureDetector(
            onPanUpdate: (details) => updateLaunchAngle(details.localPosition),
            child: Stack(
              children: [
                // 배경
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/game/background_korean_field.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (stoneVisible)
                  Positioned(
                    left: stonePosX,
                    top: stonePosY,
                    child: Image.asset(
                      'assets/game/biseok_stone.png',
                      width: stoneSize,
                      height: stoneSize,
                    ),
                  ),
                Positioned(
                  left: biseokX,
                  top: biseokY,
                  child: Image.asset(
                    'assets/game/biseok_target.png',
                    width: 30,
                    height: 60,
                  ),
                ),
                if (isHitEffectVisible)
                  Positioned(
                    left: biseokX - 40,
                    top: biseokY - 40,
                    child: Image.asset(
                      'assets/game/biseok_hit.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    '🌬️ 바람: ${getFormattedWindLabel()}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('⏱ $timeLeft초', style: const TextStyle(fontSize: 20)),
                      Text('점수: $score점', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    children: [
                      const Text('💪 힘'),
                      Container(
                        width: 30,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 30,
                            height: 150 * launchPower,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 100,
                  top: groundY,
                  child: CustomPaint(
                    painter: LaunchAnglePainter(launchAngle),
                    size: const Size(100, 100),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 40,
                  child: ElevatedButton(
                    onPressed: isStoneFlying || isGameOver || !stoneVisible
                        ? null
                        : launchStone,
                    child: const Text('🎯 발사'),
                  ),
                ),
                if (isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('게임 종료',
                              style: TextStyle(fontSize: 32, color: Colors.white)),
                          const SizedBox(height: 12),
                          Text('최종 점수: $score점',
                              style: const TextStyle(fontSize: 24, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LaunchAnglePainter extends CustomPainter {
  final double angle;
  LaunchAnglePainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(0, 0);
    final radius = 50.0;

    final arcPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3;

    final rad = angle * pi / 180;
    final arcPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0, -rad, false)
      ..close();

    canvas.drawPath(arcPath, arcPaint);

    final end = Offset(cos(-rad) * radius, sin(-rad) * radius);
    canvas.drawLine(center, end, linePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${angle.toStringAsFixed(0)}°',
        style: const TextStyle(
            color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(10, -radius - 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
