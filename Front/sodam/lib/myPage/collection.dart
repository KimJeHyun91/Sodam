import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class RewardItem {
  final String name;
  final String category; // 'A' or 'B'
  final bool owned;
  final String? imagePath; // 문양일 경우만 사용

  RewardItem({
    required this.name,
    required this.category,
    required this.owned,
    this.imagePath,
  });
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<RewardItem> titleList = [];
  List<RewardItem> patternList = [];

  String? id;

  @override
  void initState() {
    super.initState();
    fetchRewards();
  }

  Future<void> fetchRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      id = prefs.getString('loggedInId');
      if (id == null || id!.isEmpty) {
        print('❌ 유저 ID 없음');
        return;
      }

      final rewardRes = await DioClient.dio.get('/reward/get_reward_item_list');
      final ownedRes = await DioClient.dio.get('/reward/get_user_reward_item_id_list', queryParameters: {
        'id': id,
      });

      if (rewardRes.statusCode == 200 && ownedRes.statusCode == 200) {
        final List<dynamic> allItems = rewardRes.data;
        final List<dynamic> ownedItems = ownedRes.data;
        final ownedItemNos = ownedItems
            .map((item) => item['user_reward_item_id']['reward_item_no'])
            .toSet();

        List<RewardItem> titles = [];
        List<RewardItem> patterns = [];

        for (final item in allItems) {
          final rewardNo = item['reward_item_no'];
          final name = item['reward_item_name'];
          final category = item['reward_item_category'];
          final owned = ownedItemNos.contains(rewardNo);

          if (category == 'A') {
            titles.add(RewardItem(name: name, category: 'A', owned: owned));
          } else if (category == 'D') {
            patterns.add(RewardItem(
              name: name,
              category: 'D',
              owned: owned,
              imagePath: item['reward_item_image_url'],
            ));
          }
        }

        setState(() {
          titleList = titles;
          patternList = patterns;
        });
      }
    } catch (e) {
      print('리워드 아이템 가져오기 실패: $e');
    }
  }

  void _showApplyDialog(BuildContext context, RewardItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("아이템 적용"),
          content: Text('"${item.name}" 아이템을 적용하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (id == null) return;
                if (item.category == 'A') {
                  await prefs.setString('selectedTitle_$id', item.name);
                } else if (item.category == 'D') {
                  await prefs.setString('selectedIcon_$id', item.imagePath ?? '');
                }
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text("예"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("수집"),
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
            const Text("문양", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _twoLineScroll(patternList),

            const SizedBox(height: 24),
            const Text("칭호", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _twoLineScroll(titleList),
          ],
        ),
      ),
    );
  }

  Widget _twoLineScroll(List<RewardItem> items) {
    List<List<RewardItem>> rows = [[], []];
    for (int i = 0; i < items.length; i++) {
      rows[i % 2].add(items[i]);
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rows[0].length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              _collectionItem(context, rows[0][index]),
              const SizedBox(height: 12),
              if (index < rows[1].length)
                _collectionItem(context, rows[1][index]),
            ],
          );
        },
      ),
    );
  }

  Widget _collectionItem(BuildContext context, RewardItem item) {
    final isOwned = item.owned;

    return GestureDetector(
      onTap: isOwned
          ? () {
        _showApplyDialog(context, item);
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isOwned
              ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white)
              : Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: item.category == 'A'
            ? Text(
          item.name,
          style: TextStyle(
            fontSize: 14,
            color: isOwned ? Colors.black : Colors.grey[700],
          ),
        )
            : Image.asset(item.imagePath ?? '', fit: BoxFit.contain),
      ),
    );
  }
}