import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/scaffold_with_navbar.dart';
import 'package:programming_sns/features/chat/screen/chat_screen.dart';
import 'package:programming_sns/features/home/screen/home_screen.dart';
import 'package:programming_sns/temp/tempScreen.dart';

final rootNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
);
final shellNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
);

final router = Provider((ref) {
  final bottomItems = [
    ScreenB.metaData,
    HomeScreen.metaData,
    ScreenA.metaData,
    ChatScreen.metaData,
  ];

  return GoRouter(
    navigatorKey: ref.read(rootNavigatorKeyProvider),
    initialLocation: ref.read(currentBottomIndexProvider)['path'],
    routes: [
      ShellRoute(
        navigatorKey: ref.read(shellNavigatorKeyProvider),
        builder: (context, state, child) {
          return ScaffoldWithNavbar(
            bottomItems: bottomItems,
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
                ref: ref,
              );
            },
            routes: [
              GoRoute(
                path: DetailsScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const DetailsScreen(label: 'A');
                },
                // Heroアニメ
                // pageBuilder: (context, state) {
                //   return _pageAnimation(const DetailsScreen(label: 'A'), state);
                // },
                routes: [
                  GoRoute(
                    path: DetailsScreen2.path,
                    parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                    builder: (context, state) {
                      return const DetailsScreen2(label: 'A DetailsScreen2');
                    },
                    // pageBuilder: (context, state) {
                    //   return _pageAnimation(const DetailsScreen2(label: 'A DetailsScreen2'), state);
                    // },
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
                ref: ref,
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
                ref: ref,
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
          GoRoute(
            path: ChatScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const ChatScreen(),
                state,
                ref: ref,
              );
            },
          ),
        ],
      )
    ],
    redirect: (context, state) {
      final path = ref.watch(currentBottomIndexProvider)['path'];
      final uri = state.uri.toString();
      if (!uri.startsWith(path)) {
        final currentBottomIndex = ref.read(currentBottomIndexProvider.notifier).state;
        bottomItems.where((e) => uri == e['path']).forEach((e) {
          currentBottomIndex['path'] = e['path'];
          currentBottomIndex['index'] = e['index'];
        });
      }
      return;
    },
  );
});

/// ページ遷移時のアニメーション
/// ボトムナヴィのみ使用
CustomTransitionPage _pageAnimation(Widget child, GoRouterState state, {ProviderRef? ref}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: Hero(tag: '', child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (ref == null) return child;
      int preIndex = ref.read(currentBottomIndexProvider)['preIndex']!;
      int index = ref.read(currentBottomIndexProvider)['index']!;
      Offset start = Offset(index < preIndex ? -1.0 : 1.0, 0.0);
      Offset end = Offset.zero; //最終地点
      Animation<Offset> offset = Tween(begin: start, end: end).animate(animation);
      return SlideTransition(position: offset, child: child);
    },
  );
}
