// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:programming_sns/common/scaffold_with_navbar.dart';
// import 'package:programming_sns/features/home/screen/home_screen.dart';
// import 'package:programming_sns/temp/tempScreen.dart';

// final rootNavigatorKeyProvider = Provider(
//   (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
// );
// final shellNavigatorKeyProvider = Provider(
//   (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
// );

// final router = Provider((ref) {
//   CustomTransitionPage pageAnimation(Widget child, GoRouterState state) {
//     int preIndex = ref.read(currentIndexProvider)['preIndex'];
//     int index = ref.read(currentIndexProvider)['index'];
//     return CustomTransitionPage(
//       key: state.pageKey,
//       child: child,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
// // print(state)
//         // print(state.path);
//         // final flg = index < preIndex;
//         // Offset start = Offset(flg ? -1.0 : 1.0, 0.0);
//         // Offset end = Offset.zero; //最終地点
//         // Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
//         // return SlideTransition(position: offset, child: child);

//         if (!state.path!.startsWith('details')) {
//           // print('Nullではない:$tabIndex:${tabIndex.runtimeType}');
//           final flg = index < preIndex;
//           Offset start = Offset(flg ? -1.0 : 1.0, 0.0);
//           Offset end = Offset.zero; //最終地点
//           Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
//           // print('Nullではないわ:$tabIndex:${tabIndex.runtimeType}');
//           return SlideTransition(position: offset, child: child);
//         } else {
//           // print('Null:$tabIndex:${tabIndex.runtimeType}:TYPE:${child.runtimeType}');
//           return FadeTransition(opacity: animation, child: child);
//           // return Hero(tag: '', child: child);
//         }
//       },
//     );
//   }

//   return GoRouter(
//     navigatorKey: ref.read(rootNavigatorKeyProvider),
//     initialLocation: ScreenA.metaData['path'],
//     // initialExtra: ScreenA.metaData['index'],
//     routes: [
//       ShellRoute(
//         navigatorKey: ref.read(shellNavigatorKeyProvider),
//         builder: (context, state, child) {
//           return ScaffoldWithNavbar(
//             child: child,
//           );
//         },
//         routes: [
//           GoRoute(
//             path: ScreenA.metaData['path'],
//             pageBuilder: (context, state) {
//               return pageAnimation(
//                 const ScreenA(),
//                 state,
//                 // tabIndex: ScreenA.metaData['index'],
//               );
//             },
//             routes: [
//               GoRoute(
//                 path: DetailsScreen.path,
//                 parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
//                 // builder: (context, state) {
//                 //   return const Stack(
//                 //     children: [
//                 //       Hero(tag: 'A', child: DetailsScreen(label: 'A')),
//                 //     ],
//                 //   );
//                 //   return const Hero(tag: 'A', child: DetailsScreen(label: 'A'));
//                 //   return const DetailsScreen(label: 'A');
//                 // },
//                 pageBuilder: (context, state) {
//                   return pageAnimation(const DetailsScreen(label: 'A'), state);
//                 },
//                 routes: [
//                   GoRoute(
//                     path: DetailsScreen2.path,
//                     parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
//                     // builder: (context, state) {
//                     //   return const Stack(
//                     //     children: [
//                     //       Hero(tag: 'A', child: DetailsScreen2(label: 'ADetailsScreen2A')),
//                     //     ],
//                     //   );
//                     //   return const Hero(tag: 'A', child: DetailsScreen2(label: 'ADetailsScreen2'));
//                     //   return const DetailsScreen2(label: 'A DetailsScreen2');
//                     // },
//                     pageBuilder: (context, state) {
//                       return pageAnimation(const DetailsScreen2(label: 'A DetailsScreen2'), state);
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           GoRoute(
//             path: ScreenB.metaData['path'],
//             pageBuilder: (context, state) {
//               return pageAnimation(
//                 const ScreenB(),
//                 state,
//                 // tabIndex: ScreenB.metaData['index'],
//               );
//             },
//             // pageBuilder: (context, state) {
//             //   return CustomTransitionPage(
//             //     key: state.pageKey,
//             //     child: const Hero(tag: '', child: ScreenB()),
//             //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             //       final flg = TabItem.screenB.index < (state.extra as int);
//             //       Offset start = Offset(flg ? -1.0 : 1.0, 0.0); //出てくる場所
//             //       Offset end = Offset.zero; //最終地点
//             //       Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);

//             //       return SlideTransition(position: offset, child: child);
//             //     },
//             //   );
//             // },
//             routes: [
//               GoRoute(
//                 path: DetailsScreen.path,
//                 parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
//                 builder: (context, state) {
//                   return const DetailsScreen(label: 'B');
//                 },
//               ),
//             ],
//           ),
//           GoRoute(
//             path: HomeScreen.metaData['path'],
//             pageBuilder: (context, state) {
//               return pageAnimation(
//                 const HomeScreen(),
//                 state,
//                 // tabIndex: HomeScreen.metaData['index'],
//               );
//               // return CustomTransitionPage(
//               //   key: state.pageKey,
//               //   child: const Hero(tag: '', child: HomeScreen()),
//               //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
//               //     Offset start = const Offset(1.0, 0.0); //出てくる場所
//               //     Offset end = Offset.zero; //最終地点
//               //     Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
//               //     return SlideTransition(position: offset, child: child);
//               //   },
//               // );
//             },
//             routes: [
//               GoRoute(
//                 path: DetailsScreen.path,
//                 parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
//                 builder: (context, state) {
//                   return const DetailsScreen(label: 'HOME');
//                 },
//               ),
//             ],
//           ),
//         ],
//       )
//     ],
//   );
// });
