import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/features/home/screen/home_screen.dart';
import 'package:programming_sns/temp/tempScreen.dart';

// final currentIndexProvider = StateProvider(
//   (_) => TabItem.screenA.index,
// );

class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar({super.key, required this.child});
  final Widget child;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  int curentIndex = ScreenA.metaData['index'];
  @override
  Widget build(BuildContext context) {
    final bottomItems = [ScreenA.metaData, ScreenB.metaData, HomeScreen.metaData];

    return Scaffold(
      body: (widget.child as HeroControllerScope).child,
      bottomNavigationBar: BottomNavigationBar(
        items: bottomItems
            .map((meta) => BottomNavigationBarItem(icon: meta['icon'], label: meta['label']))
            .toList(),
        currentIndex: curentIndex,
        onTap: (index) {
          final preIndex = curentIndex;
          setState(() {
            curentIndex = index;
            context.go(bottomItems[index]['path'], extra: preIndex);
          });
        },
      ),
    );
  }
}
