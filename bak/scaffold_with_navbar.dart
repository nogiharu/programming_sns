// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:programming_sns/features/home/screen/home_screen.dart';
// import 'package:programming_sns/temp/tempScreen.dart';


// final currentIndexProvider = StateProvider((ref) {
//   return {
//     'index': ScreenA.metaData['index'],
//     'preIndex': ScreenA.metaData['index'],
//   };
// });

// class ScaffoldWithNavbar extends ConsumerWidget {
//   const ScaffoldWithNavbar({super.key, required this.child});
//   final Widget child;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final curentIndex = ref.read(currentIndexProvider.notifier).state;

//     final bottomItems = [
//       ScreenB.metaData,
//       HomeScreen.metaData,
//       ScreenA.metaData,
//     ];

//     bottomItems.sort((a, b) => a['index'].compareTo(b['index']));

//     return Scaffold(
//       body: (child as HeroControllerScope).child,
//       bottomNavigationBar: BottomNavigationBar(
//         items: bottomItems
//             .map(
//               (meta) => BottomNavigationBarItem(
//                 icon: meta['icon'],
//                 label: meta['label'],
//               ),
//             )
//             .toList(),
//         currentIndex: ref.watch(currentIndexProvider)['index'],
//         onTap: (index) {
//           curentIndex['preIndex'] = curentIndex['index'];
//           curentIndex['index'] = index;
//           context.go(bottomItems[index]['path']);
//         },
//       ),
//     );
//   }
// }
