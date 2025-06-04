import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dio_client.dart';
import '../point_util.dart';
import '../game_page.dart';

class RockPaperScissorsPage extends StatefulWidget {
  final String myNickname;
  final String opponentNickname;

  const RockPaperScissorsPage({
    super.key,
    required this.myNickname,
    required this.opponentNickname,
  });

  @override
  State<RockPaperScissorsPage> createState() => _RockPaperScissorsPageState();
}

class _RockPaperScissorsPageState extends State<RockPaperScissorsPage> {
  final choices = ['가위', '바위', '보'];
  int round = 1;
  int myScore = 0;
  int opponentScore = 0;
  String? myChoice;
  String? opponentChoice;
  String? winnerNickname;
  String result = '';
  bool showChoices = false;
  bool countdownEnded = false;
  String? countdownText;
  int timeLeft = 5;
  Timer? timer;
  bool gameEnded = false; // ✅ 게임 종료 플래그 추가

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  Future<void> refreshPoint() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('loggedInId');

    if (id == null) return;

    try {
      final res = await DioClient.dio.get(
        '/point/get_info_id_object',
        queryParameters: {'id': id},
      );

      final data = res.data;

      // ✅ 방어 코드 추가
      if (data is! Map || !data.containsKey('current_point')) {
        print('❌ 응답이 JSON이 아님 또는 current_point 없음: $data');
        return;
      }

      final point = data['current_point'];
      print('✅ 최신 포인트: $point');

      // 예: setState(() { myPoint = point; }); → 필요 시 UI 갱신

    } catch (e) {
      print('❌ 포인트 갱신 실패: $e');
    }
  }

  Future<void> startCountdown() async {
    for (int i = 3; i >= 1; i--) {
      setState(() {
        countdownText = '$i';
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() {
      countdownText = null;
      countdownEnded = true;
    });
    startTimer();
  }

  void startTimer() {
    timeLeft = 5;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        if (myChoice == null) selectMyChoice(choices[0]);
        if (opponentChoice == null) selectOpponentChoice(choices[1]);
      }
    });
  }

  void selectMyChoice(String choice) {
    if (myChoice != null || !countdownEnded || gameEnded) return;
    setState(() {
      myChoice = choice;
      checkResult();
    });
  }

  void selectOpponentChoice(String choice) {
    if (opponentChoice != null || !countdownEnded || gameEnded) return;
    setState(() {
      opponentChoice = choice;
      checkResult();
    });
  }

  void checkResult() {
    if (myChoice != null && opponentChoice != null) {
      timer?.cancel();
      showChoices = true;
      result = judge(myChoice!, opponentChoice!);

      if (result.contains('비겼습니다')) {
        Future.delayed(const Duration(seconds: 1), () {
          showRoundResultDialog('무승부입니다.');
        });
        return;
      }

      if (winnerNickname == widget.myNickname) {
        myScore++;
      } else {
        opponentScore++;
      }

      Future.delayed(const Duration(seconds: 1), () {
        showRoundResultDialog('$winnerNickname 승!');
      });
    }
  }

  String getKoreanRound(int number) {
    switch (number) {
      case 1:
        return '첫 번째 판';
      case 2:
        return '두 번째 판';
      case 3:
        return '세 번째 판';
      default:
        return '';
    }
  }

  String getImageForChoice(String choice) {
    switch (choice) {
      case '가위':
        return 'assets/game/scissors.png';
      case '바위':
        return 'assets/game/rock.png';
      case '보':
        return 'assets/game/paper.png';
      default:
        return '';
    }
  }


  String judge(String my, String opponent) {
    if (my == opponent) return '비겼습니다!';
    bool iWin = (my == '가위' && opponent == '보') ||
        (my == '바위' && opponent == '가위') ||
        (my == '보' && opponent == '바위');
    winnerNickname = iWin ? widget.myNickname : widget.opponentNickname;
    return '${winnerNickname!} 승!';
  }

  void showFinalDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void showFinalResult() {
    String finalMessage;
    final isMyWin = myScore > opponentScore;

    if (isMyWin) {
      finalMessage = '${widget.myNickname} 승리! 🎉 엽전 50냥 획득';
    } else if (myScore < opponentScore) {
      finalMessage = '${widget.opponentNickname} 승리! ❌ 엽전 획득 실패';
    } else {
      finalMessage = '무승부! 🤝';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Center(child: Text('최종 결과', textAlign: TextAlign.center)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              finalMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              if (myScore > opponentScore) {
                await giveReward(50, reasonCode: 'RPS_WIN');
                await refreshPoint();
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GamePage()),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void showRoundResultDialog(String resultMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Center( // ✅ 제목 가운데 정렬
          child: Text(
            '${getKoreanRound(round)} 결과',
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ Column 내부 가운데 정렬
          children: [
            Text(
              '${widget.myNickname}의 선택: $myChoice',
              textAlign: TextAlign.center, // ✅ 텍스트 가운데
            ),
            Text(
              '${widget.opponentNickname}의 선택: $opponentChoice',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              resultMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (myScore == 2 || opponentScore == 2 || round == 3) {
        showFinalResult(); // 게임 종료
      } else {
        setState(() {
          round++;
          myChoice = null;
          opponentChoice = null;
          winnerNickname = null;
          result = '';
          showChoices = false;
          countdownEnded = false;
        });
        startCountdown();
      }
    });
  }

  Widget buildImageChoice(String choice, String assetPath) {
    final isSelected = myChoice == choice;

    return GestureDetector(
      onTap: countdownEnded && !showChoices && !gameEnded
          ? () => selectMyChoice(choice)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 3,
          ),
        ),
        child: Image.asset(
          assetPath,
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        title: Text('가위바위보 - ${getKoreanRound(round)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: countdownText != null
            ? Center(
          child: Text(
            countdownText!,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : Column(
          children: [
            if (!showChoices && !gameEnded) Text('선택 남은 시간: $timeLeft초'),
            const SizedBox(height: 20),
            if (result.isNotEmpty)
              Text(
                result,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 나의 선택
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildImageChoice('가위', 'assets/game/scissors.png'),
                      buildImageChoice('바위', 'assets/game/rock.png'),
                      buildImageChoice('보', 'assets/game/paper.png'),
                    ],
                  ),

                  // 상대방 선택
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showChoices && opponentChoice != null)
                        Image.asset(
                          getImageForChoice(opponentChoice!),
                          width: 100,
                          height: 100,
                        )
                      else
                        const Text('상대 선택 대기중...'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}