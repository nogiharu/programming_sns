import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../lib2/core/enums/tab_item.dart';

final currentIndexProvider = StateProvider(
  (_) => TabItem.screenA.index,
);

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indexNotifier = ref.read(currentIndexProvider.notifier);

    return Scaffold(
      body: (child as HeroControllerScope).child,
      bottomNavigationBar: BottomNavigationBar(
        items: TabItem.values
            .map((tabItem) => BottomNavigationBarItem(
                  icon: tabItem.icon,
                  label: tabItem.label,
                ))
            .toList(),
        currentIndex: ref.watch(currentIndexProvider),
        onTap: (index) {
          final preIndex = indexNotifier.state;
          indexNotifier.state = index;
          context.go(TabItem.values[indexNotifier.state].path, extra: preIndex);
        },
      ),
    );
  }
}
