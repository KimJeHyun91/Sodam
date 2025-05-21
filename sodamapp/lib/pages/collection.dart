import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("수집"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("문양", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _twoLineScroll([
              "assets/images/icon1.png",
              "assets/images/icon2.png",
              "assets/images/icon3.png",
              "assets/images/icon4.png",
              "assets/images/icon5.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",
              "assets/images/icon6.png",

            ]),

            const SizedBox(height: 24),
            const Text("칭호", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _twoLineScroll([
              "성실한", "승부사", "패배자", "수다쟁이", "관찰자", "성실한", "승부사", "패배자", "수다쟁이", "관찰자"
            ], isText: true),
          ],
        ),
      ),
    );
  }

  Widget _twoLineScroll(List items, {bool isText = false}) {
    // 한 줄에 최대 3개씩 2줄씩 나누기
    List<List> rows = [[], []];
    for (int i = 0; i < items.length; i++) {
      rows[i % 2].add(items[i]);
    }

    return SizedBox(
      height: 200, // 전체 높이 (두 줄 포함)
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rows[0].length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              _collectionItem(rows[0][index], isText),
              const SizedBox(height: 12),
              if (index < rows[1].length)
                _collectionItem(rows[1][index], isText),
            ],
          );
        },
      ),
    );
  }

  Widget _collectionItem(dynamic data, bool isText) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isText
          ? Text(data, style: const TextStyle(fontSize: 14))
          : Image.asset(data, fit: BoxFit.contain),
    );
  }
}