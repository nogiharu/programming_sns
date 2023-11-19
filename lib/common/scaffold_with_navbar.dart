import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final currentBottomMap = ref.read(currentBottomIndexProvider);

    return Scaffold(
      body: (child as HeroControllerScope).child,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        unselectedItemColor: Colors.grey,
        // unselectedLabelStyle: const TextStyle(color: Colors.grey),
        items: bottomItems
            .map(
              (meta) => BottomNavigationBarItem(
                icon: meta['icon'],
                label: meta['label'],
              ),
            )
            .toList(),
        currentIndex: ref.watch(currentBottomIndexProvider)['index']!,
        onTap: (index) {
          currentBottomMap['preIndex'] = currentBottomMap['index']!;
          currentBottomMap['index'] = index;
          context.go(bottomItems[index]['path']);
        },
      ),
    );
  }
}
