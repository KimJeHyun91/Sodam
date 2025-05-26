import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("장터"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("배경", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, [
              _storeItem(context, "assets/images/bg_pink.png", "100 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
              _storeItem(context, "assets/images/bg_gray.png", "500 냥"),

            ]),

            const SizedBox(height: 24),

            const Text("틀", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, [
              _storeItem(context, "assets/images/face_rain.png", "1,000 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),

            ]),

            const SizedBox(height: 24),

            const Text("딱지", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, [
              _storeItem(context, "assets/images/face_rain.png", "1,000 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),

            ]),

            const SizedBox(height: 24),

            const Text("직업", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, [
              _storeItem(context, "assets/images/face_rain.png", "1,000 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
              _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),

            ]),
          ],
        ),
      ),
    );
  }

  Widget _horizontalItemScroll(BuildContext context, List<Widget> items) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => items[index],
      ),
    );
  }

  Widget _storeItem(BuildContext context, String imagePath, String price, {String? title}) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),

          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 14)),
          const Text("구매하기", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}