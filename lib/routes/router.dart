import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/scaffold_with_navbar.dart';
import 'package:programming_sns/features/home/screen/home_screen.dart';
import 'package:programming_sns/temp/tempScreen.dart';

final rootNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
);
final shellNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
);

final router = Provider((ref) {
  return GoRouter(
    navigatorKey: ref.read(rootNavigatorKeyProvider),
    initialLocation: ScreenA.metaData['path'],
    routes: [
      ShellRoute(
        navigatorKey: ref.read(shellNavigatorKeyProvider),
        builder: (context, state, child) {
          return ScaffoldWithNavbar(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: ScreenA.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const ScreenA(),
                state,
                ref,
              );
            },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const DetailsScreen(label: 'A');
                },
                routes: [
                  GoRoute(
                    path: DetailsScreen2.path,
                    parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                    builder: (context, state) {
                      return const DetailsScreen2(label: 'A DetailsScreen2');
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: ScreenB.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const ScreenB(),
                state,
                ref,
              );
            },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const DetailsScreen(label: 'B');
                },
              ),
            ],
          ),
          GoRoute(
            path: HomeScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const HomeScreen(),
                state,
                ref,
              );
            },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const DetailsScreen(label: 'HOME');
                },
              ),
            ],
          ),
        ],
      )
    ],
  );
});

CustomTransitionPage _pageAnimation(Widget child, GoRouterState state, ProviderRef ref) {
  int preIndex = ref.read(currentIndexProvider)['preIndex'];
  int index = ref.read(currentIndexProvider)['index'];
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final flg = index < preIndex;
      Offset start = Offset(flg ? -1.0 : 1.0, 0.0);
      Offset end = Offset.zero; //最終地点
      Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
      return SlideTransition(position: offset, child: child);
    },
  );
}
