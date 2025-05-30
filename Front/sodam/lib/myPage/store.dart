// import 'package:flutter/material.dart';
//
// import '../dio_client.dart';
//
// class StoreItem {
//   final String name;
//   final String category;
//   final String imagePath;
//   final int price;
//
//   StoreItem({
//     required this.name,
//     required this.category,
//     required this.imagePath,
//     required this.price,
//   });
//
//   factory StoreItem.fromJson(Map<String, dynamic> json) {
//     return StoreItem(
//       name: json['reward_item_name'],
//       category: json['reward_item_category'],
//       imagePath: json['reward_item_image_url'],
//       price: json['reward_item_price'],
//     );
//   }
// }
//
// class StorePage extends StatefulWidget {
//   const StorePage({super.key});
//
//   Future<void> fetchStoreItems() async {
//     try {
//       final response = await DioClient.dio.get('/reward/get_reward_item_list');
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//
//         final List<StoreItem> backgrounds = [];
//         final List<StoreItem> frames = [];
//         final List<StoreItem> cards = [];
//
//         for (final item in data) {
//           final storeItem = StoreItem.fromJson(item);
//           switch (storeItem.category) {
//             case 'B': backgrounds.add(storeItem); break;
//             case 'C': frames.add(storeItem); break;
//             case 'E': cards.add(storeItem); break;
//           }
//         }
//
//         setState(() {
//           backgroundItems = backgrounds;
//           frameItems = frames;
//           cardItems = cards;
//         });
//       }
//     } catch (e) {
//       print('🧨 장터 아이템 불러오기 실패: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("장터"),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
//         elevation: 0,
//       ),
//       backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("배경", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _horizontalItemScroll(context, [
//               _storeItem(context, "assets/images/bg_pink.png", "100 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//               _storeItem(context, "assets/images/bg_gray.png", "500 냥"),
//
//             ]),
//
//             const SizedBox(height: 24),
//
//             const Text("틀", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _horizontalItemScroll(context, [
//               _storeItem(context, "assets/images/icon1.png", "1,000 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//
//             ]),
//
//             const SizedBox(height: 24),
//
//             const Text("딱지", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _horizontalItemScroll(context, [
//               _storeItem(context, "assets/images/face_rain.png", "1,000 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//
//             ]),
//
//             const SizedBox(height: 24),
//
//             const Text("직업", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _horizontalItemScroll(context, [
//               _storeItem(context, "assets/images/face_rain.png", "1,000 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//               _storeItem(context, "assets/images/face_gold.png", "1,500 냥"),
//
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _horizontalItemScroll(BuildContext context, List<Widget> items) {
//     return SizedBox(
//       height: 220,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) => items[index],
//       ),
//     );
//   }
//
//   // Widget _storeItem(BuildContext context, String imagePath, String price, {String? title}) {
//   //   return Container(
//   //     width: 140,
//   //     decoration: BoxDecoration(
//   //       color: Theme.of(context).brightness == Brightness.dark
//   //           ? Colors.grey[850]
//   //           : Colors.white,        borderRadius: BorderRadius.circular(16),
//   //     ),
//   //     padding: const EdgeInsets.all(12),
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         if (title != null)
//   //           Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//   //
//   //         const SizedBox(height: 8),
//   //
//   //         Expanded(
//   //           child: Image.asset(imagePath, fit: BoxFit.contain),
//   //         ),
//   //
//   //         const SizedBox(height: 8),
//   //         Text(price, style: const TextStyle(fontSize: 14)),
//   //         const Text("구매하기", style: TextStyle(fontSize: 14)),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _storeItem(BuildContext context, StoreItem item) {
//     return Container(
//       width: 140,
//       decoration: BoxDecoration(
//         color: Theme.of(context).brightness == Brightness.dark
//             ? Colors.grey[850]
//             : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Expanded(child: Image.asset(item.imagePath, fit: BoxFit.contain)),
//           const SizedBox(height: 8),
//           Text("${item.price} 냥", style: const TextStyle(fontSize: 14)),
//           const Text("구매하기", style: TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class StoreItem {
  final String name;
  final String category;
  final String imagePath;
  final int price;

  StoreItem({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.price,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      name: json['reward_item_name'],
      category: json['reward_item_category'],
      imagePath: json['reward_item_image_url'],
      price: json['reward_item_price'],
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<StoreItem> backgroundItems = [];
  List<StoreItem> frameItems = [];
  List<StoreItem> cardItems = [];

  @override
  void initState() {
    super.initState();
    fetchStoreItems();
  }

  Future<void> fetchStoreItems() async {
    try {
      final response = await DioClient.dio.get('/reward/get_reward_item_list');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<StoreItem> backgrounds = [];
        final List<StoreItem> frames = [];
        final List<StoreItem> cards = [];

        for (final item in data) {
          final storeItem = StoreItem.fromJson(item);
          switch (storeItem.category) {
            case 'T': backgrounds.add(storeItem); break;
            case 'F': frames.add(storeItem); break;
            case 'C': cards.add(storeItem); break;
          }
        }

        setState(() {
          backgroundItems = backgrounds;
          frameItems = frames;
          cardItems = cards;
        });
      }
    } catch (e) {
      print('🧨 장터 아이템 불러오기 실패: $e');
    }
  }

  Widget _horizontalItemScroll(BuildContext context, List<StoreItem> items) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _storeItem(context, items[index]),
      ),
    );
  }

  Widget _storeItem(BuildContext context, StoreItem item) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(child: Image.asset(item.imagePath, fit: BoxFit.contain)),
          const SizedBox(height: 8),
          Text("${item.price} 냥", style: const TextStyle(fontSize: 14)),
          const Text("구매하기", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

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
            _horizontalItemScroll(context, backgroundItems),

            const SizedBox(height: 24),
            const Text("틀", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, frameItems),

            const SizedBox(height: 24),
            const Text("딱지", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _horizontalItemScroll(context, cardItems),
          ],
        ),
      ),
    );
  }
}