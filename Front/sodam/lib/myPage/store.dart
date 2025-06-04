import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class StoreItem {
  final String name;
  final String category;
  final String imagePath;
  final int price;
  final int rewardItemNo;

  StoreItem({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.price,
    required this.rewardItemNo,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      name: json['reward_item_name'],
      category: json['reward_item_category'],
      imagePath: json['reward_item_image_url'],
      price: json['reward_item_price'],
      rewardItemNo: json['reward_item_no'],
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
  List<int> ownedItemNos = [];

  @override
  void initState() {
    super.initState();
    fetchStoreItems();
    fetchOwnedItems();
  }

  Future<void> fetchOwnedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId') ?? '';
      if (id.isEmpty) return;

      final response = await DioClient.dio.get('/reward/get_user_reward_item_list?id=$id');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // setState(() {
        //   ownedItemNos = data.map<int>((e) => e['reward_item_no'] as int).toList();
        // });
        setState(() {
          ownedItemNos = data.map<int>((e) {
            final idObj = e['user_reward_item_id'];
            if (idObj != null && idObj['reward_item_no'] != null) {
              return idObj['reward_item_no'] as int;
            } else {
              throw Exception("Invalid user_reward_item_id structure: $e");
            }
          }).toList();
        });
      }
    } catch (e) {
      print('🧨 보유 아이템 불러오기 실패: $e');
    }
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

  void _showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("알림"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          )
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext scaffoldContext, StoreItem item) async {
    if (ownedItemNos.contains(item.rewardItemNo)) {
      _showResultDialog(scaffoldContext, "이미 보유한 아이템입니다!");
      return;
    }

    final confirm = await showDialog<bool>(
      context: scaffoldContext,
      builder: (ctx) => AlertDialog(
        title: const Text("아이템 구매"),
        content: Text('"${item.name}"을(를) 구매하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("예")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('loggedInId') ?? '';
      if (id.isEmpty) {
        _showResultDialog(scaffoldContext, "로그인 정보가 없습니다.");
        return;
      }

      final pointRes = await DioClient.dio.get('/point/get_info_id_object?id=$id');
      final pointData = pointRes.data;
      final int myPoint = pointData['current_point'] ?? 0;
      final int pointNo = pointData['point_no'];

      if (myPoint < item.price) {
        _showResultDialog(scaffoldContext, "포인트가 부족합니다!");
        return;
      }

      final rewardRes = await DioClient.dio.post('/reward/add_user_reward_item', data: {
        'id': id,
        'reward_item_no': item.rewardItemNo,
      });

      if (rewardRes.statusCode == 200 && rewardRes.data == 1200) {
        final historyRes = await DioClient.dio.post('/point/create_history', data: {
          'point_no': pointNo,
          'change_amount': item.price,
          'point_plus_minus': 'M',
          'point_change_reason_code': 'BUY',
        });

        if (historyRes.statusCode == 200 && historyRes.data == 11) {
          _showResultDialog(scaffoldContext, "구매가 완료되었습니다!");
          setState(() {
            ownedItemNos.add(item.rewardItemNo);
          });
        } else {
          _showResultDialog(scaffoldContext, "포인트 기록 실패 (${historyRes.data})");
        }
      } else if (rewardRes.data == 1201) {
        _showResultDialog(scaffoldContext, "이미 보유한 아이템입니다!");
      } else {
        _showResultDialog(scaffoldContext, "구매에 실패했습니다. (${rewardRes.data})");
      }
    } catch (e) {
      _showResultDialog(scaffoldContext, "구매 중 오류 발생: $e");
    }
  }

  void _showApplyFrameDialog(BuildContext context, StoreItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("프레임 적용"),
          content: Text('"${item.name}" 프레임을 적용하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString('loggedInId');
                if (id == null) return;

                // await prefs.setString('selectedFrame_$id', item.imagePath);
                if (item.imagePath != null) {
                  await prefs.setString('selectedFrame_$id', item.imagePath!);
                  print('✅ 프레임 저장됨 [selectedFrame_$id]: ${item.imagePath!}');
                } else {
                  print('❌ 프레임 이미지 경로가 null입니다: ${item.name}');
                }
                Navigator.pop(context);
                Navigator.pop(context, true); // 필요시 상위로 결과 전달
              },
              child: const Text("예"),
            ),
          ],
        );
      },
    );
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
    final bool isOwned = ownedItemNos.contains(item.rewardItemNo);
    return GestureDetector(
      onTap: () {
        if (!isOwned) {
          _showPurchaseDialog(context, item);
        } else {
          _showApplyFrameDialog(context, item);
        }
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isOwned ? Colors.grey[300] : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white),
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
            Text(isOwned ? "보유중" : "구매하기", style: const TextStyle(fontSize: 14)),
          ],
        ),
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