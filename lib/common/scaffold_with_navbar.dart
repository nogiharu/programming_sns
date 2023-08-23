import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/temp/tempScreen.dart';

final currentBottomIndexProvider = StateProvider((ref) {
  return {
    'path': ScreenA.metaData['path'],
    'index': ScreenA.metaData['index'],
    'preIndex': ScreenA.metaData['index'],
  };
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
    bottomItems.sort((a, b) => a['index'].compareTo(b['index']));

    final curentIndex = ref.read(currentBottomIndexProvider.notifier).state;

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
          curentIndex['preIndex'] = curentIndex['index']!;
          curentIndex['index'] = index;
          context.go(bottomItems[index]['path']);
        },
      ),
    );
  }
}
