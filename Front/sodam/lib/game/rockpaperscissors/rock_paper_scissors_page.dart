import 'package:flutter/material.dart';

class RockPaperScissorsPage extends StatefulWidget {
  final String myNickname;
  final String opponentNickname;

  const RockPaperScissorsPage({super.key, required this.myNickname,
                                          required this.opponentNickname,});

  @override
  State<RockPaperScissorsPage> createState() => _RockPaperScissorsPageState();
}

class _RockPaperScissorsPageState extends State<RockPaperScissorsPage> {
  String? myChoice;
  String? opponentChoice;
  String? winnerNickname;
  String result = ''; // 결과 메세지 저장
  bool showChoices = false; // 둘 다 선택했을 때만 ture가 돼서 공개!

  final choices = ['가위', '바위', '보'];

  void selectMyChoice(String choice) {
    if (myChoice != null || showChoices) return;
    setState(() {
      myChoice = choice;
      checkResult();
    });
  }

  void selectOpponentChoice(String choice) {
    if (opponentChoice != null || showChoices) return;
    setState(() {
      opponentChoice = choice;
      checkResult();
    });
  }

  void checkResult() {
    if (myChoice != null && opponentChoice != null) {
      showChoices = true;
      result = judge(myChoice!, opponentChoice!);
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

  String getPersonalResult() {
    if (!showChoices) return '';
    if (result.contains('비겼습니다')) return '🤝 비겼습니다! 다시 도전하세요.';
    return (winnerNickname == widget.myNickname)
        ? '🎉 승리! 1냥 획득!'
        : '❌ 패배! 획득한 엽전이 없습니다.';
  }
  
  void resetGame() {
    setState(() {
      myChoice = null;
      opponentChoice = null;
      winnerNickname = null;
      result = '';
      showChoices = false;
    });
  }

  Widget buildChoiceButton(String choice, {required bool isMine}) { 
    final selected = isMine ? myChoice : opponentChoice;
    final isSelected = selected == choice;

    final onTap = showChoices
        ? null
        : () => isMine ? selectMyChoice(choice) : selectOpponentChoice(choice);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.amber : Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: isSelected ? 6 : 2,
        shadowColor: isSelected ? Colors.orangeAccent : Colors.black26,
      ),
      child: Text(
          '${isMine ? widget.myNickname : widget.opponentNickname} : $choice',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0), // 연한 배경
      appBar: AppBar(
        title: const Text('가위바위보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text('${widget.myNickname} 선택: ${showChoices ? myChoice : "?"}'),
            Text('${widget.opponentNickname} 선택: ${showChoices ? opponentChoice : "?"}'),
            const SizedBox(height: 20),
            if (result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
            Text(
              getPersonalResult(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: choices.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: buildChoiceButton(c, isMine: true),
                    )).toList(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: choices.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: buildChoiceButton(c, isMine: false),
                    )).toList(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9DAB2),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('다시하기', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
