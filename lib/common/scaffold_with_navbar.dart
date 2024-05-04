import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';

final currentBottomIndexProvider = Provider<Map<String, int>>((_) => {
      'index': 0,
      'preIndex': 0,
    });

class ScaffoldWithNavbar extends ConsumerWidget {
  const ScaffoldWithNavbar({
    super.key,
    required this.child,
    required this.bottomItems,
  });
  final Widget child;
  final List<Map<String, dynamic>> bottomItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ボトムアイテム
    // 通知だけカウントを付与
    final iconLabelItems = ref.watch(notificationListProvider).maybeWhen(
          data: (data) => bottomItems.map((meta) {
            if (meta['label'] == '通知') {
              meta['icon'] = NotificationScreen.getIconBadge(
                notificationCount: data.where((e) => !e.isRead).length,
              );
            }
            return BottomNavigationBarItem(icon: meta['icon'], label: meta['label']);
          }).toList(),
          orElse: () => bottomItems
              .map((meta) => BottomNavigationBarItem(icon: meta['icon'], label: meta['label']))
              .toList(),
        );

    return Scaffold(
      body: (child as HeroControllerScope).child,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        unselectedItemColor: Colors.grey,
        // unselectedLabelStyle: const TextStyle(color: Colors.grey),
        items: iconLabelItems,
        currentIndex: ref.watch(currentBottomIndexProvider)['index']!,
        onTap: (index) {
          final currentBottomMap = ref.read(currentBottomIndexProvider);

          currentBottomMap['preIndex'] = currentBottomMap['index']!;
          currentBottomMap['index'] = index;
          context.goNamed(bottomItems[index]['path']);
        },
      ),
    );
  }
}
