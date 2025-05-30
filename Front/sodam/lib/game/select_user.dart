import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'ttagji/ttagji_game_page.dart'; // 딱지치기
import 'biseok/biseok_game_page.dart'; // 비석치기
import 'paeng-i/spinner_selection_page.dart'; // 팽이 선택 페이지
import 'rockpaperscissors/rock_paper_scissors_page.dart';

class SelectUserPage extends StatefulWidget {
  final String gameTitle; // 예: '딱지치기', '산가지', '남승도', '팽이치기'

  const SelectUserPage({super.key, required this.gameTitle});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  final List<Map<String, dynamic>> users = [
    {
      "name": "김제현",
      "email": "kjh910920",
      "avatar": "assets/profile1.png",
      "checked": true,
    },
    {
      "name": "이하늘",
      "email": "harull817@gmail.com",
      "avatar": "assets/profile2.png",
      "checked": true,
    },
    {
      "name": "정용태",
      "email": "grand7246@gmail.com",
      "avatar": "assets/profile3.png",
      "checked": false,
    },
    {
      "name": "김기찬",
      "email": "",
      "avatar": "assets/profile4.png",
      "checked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.gameTitle} - 놀이 상대 선택"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("이웃", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(user["avatar"]),
                          radius: 22,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user["name"],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              if (user["email"] != "")
                                Text(user["email"],
                                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: user["checked"],
                          onChanged: (val) {
                            setState(() {
                              users[index]["checked"] = val!;
                            });
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.gameTitle == '딱지치기') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TtagjiGamePage()),
                    );
                  } else if (widget.gameTitle == '비석치기') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BiseokGamePage()),
                    );
                  } else if (widget.gameTitle == '팽이치기') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpinnerSelectionPage()),
                    );
                  } else if (widget.gameTitle == '가위바위보') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RockPaperScissorsPage(
                          myNickname: '나',
                          opponentNickname: '길동이',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9DAB2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("게임시작", style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
