import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../lib2/common/scaffold_with_navbar.dart';
import '../../lib2/core/enums/tab_item.dart';
import '../../lib2/features/home/screen/home_screen.dart';
import '../../lib2/temp/tempScreen.dart';

final rootNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
);
final shellNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
);

final router = Provider((ref) {
  return GoRouter(
    navigatorKey: ref.read(rootNavigatorKeyProvider),
    initialLocation: ScreenA.path,
    initialExtra: TabItem.screenA.index,
    routes: [
      ShellRoute(
        navigatorKey: ref.read(shellNavigatorKeyProvider),
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: ScreenA.path,
            // pageBuilder: (context, state) {
            //   return pageAnimation(const ScreenA(), state, TabItem.screenA.index);
            // },
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const Hero(tag: '', child: ScreenA()),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  print('AAA');
                  Offset start = const Offset(-1.0, 0.0); //出てくる場所
                  Offset end = Offset.zero; //最終地点
                  Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);

                  return SlideTransition(position: offset, child: child);
                },
              );
            },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const Hero(tag: '', child: DetailsScreen(label: 'A'));
                },
              ),
            ],
          ),
          GoRoute(
            path: ScreenB.path,
            pageBuilder: (context, state) {
              return pageAnimation(const ScreenB(), state, TabItem.screenB.index);
            },
            // pageBuilder: (context, state) {
            //   return CustomTransitionPage(
            //     key: state.pageKey,
            //     child: const Hero(tag: '', child: ScreenB()),
            //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //       final flg = TabItem.screenB.index < (state.extra as int);
            //       Offset start = Offset(flg ? -1.0 : 1.0, 0.0); //出てくる場所
            //       Offset end = Offset.zero; //最終地点
            //       Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);

            //       return SlideTransition(position: offset, child: child);
            //     },
            //   );
            // },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const Hero(tag: '', child: DetailsScreen(label: 'B'));
                },
              ),
            ],
          ),
          GoRoute(
            path: HomeScreen.path,
            pageBuilder: (context, state) {
              return pageAnimation(const HomeScreen(), state, TabItem.home.index);
              // return CustomTransitionPage(
              //   key: state.pageKey,
              //   child: const Hero(tag: '', child: HomeScreen()),
              //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
              //     Offset start = const Offset(1.0, 0.0); //出てくる場所
              //     Offset end = Offset.zero; //最終地点
              //     Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
              //     return SlideTransition(position: offset, child: child);
              //   },
              // );
            },
          ),
        ],
      )
    ],
  );
});

CustomTransitionPage pageAnimation(
  Widget child,
  GoRouterState state,
  int tabIndex,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: Hero(tag: '', child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final flg = tabIndex < (state.extra as int);
      Offset start = Offset(flg ? -1.0 : 1.0, 0.0);
      Offset end = Offset.zero; //最終地点
      Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);

      return SlideTransition(position: offset, child: child);
    },
  );
}
