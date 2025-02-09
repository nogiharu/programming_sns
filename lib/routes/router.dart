import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/widgets/scaffold_with_navbar.dart';
import 'package:programming_sns/features/auth/screens/auth_update_screen.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/chat/screens/chat_thread_screen.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/screens/user_screen.dart';

import 'package:programming_sns/test_tool.dart';

/// ScaffoldWithNavbarの外側のスコープ
/// navigatorKey:に設定するとボトムナビバーが出ない
final rootNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
);

/// ScaffoldWithNavbarの内側のスコープ
/// navigatorKey:に設定するとボトムナビバーが出る
final shellNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
);

final router = Provider((ref) {
  // タブの順番
  final bottomItems = [
    TestToolcreen.metaData,
    ChatThreadScreen.metaData,
    // ScreenB.metaData,
    NotificationScreen.metadata,
    UserScreen.metaData,
  ];

  if (kReleaseMode) {
    bottomItems.removeWhere((e) => e['path'] == TestToolcreen.metaData['path']);
  }

  return GoRouter(
    navigatorKey: ref.read(rootNavigatorKeyProvider),
    // initialLocation: bottomItems.first['path'],
    initialLocation: UserScreen.metaData['path'],
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
            path: TestToolcreen.metaData['path'],
            name: TestToolcreen.metaData['path'],
            // parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
            builder: (context, state) {
              return const TestToolcreen();
            },
          ),

          /// CHAT
          GoRoute(
            path: ChatThreadScreen.metaData['path'],
            name: ChatThreadScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(const ChatThreadScreen(), state, ref: ref);
            },
            routes: [
              GoRoute(
                path: ChatScreen.path,
                // name: nameは一意出なければならない
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  final map = state.extra as Map<String, dynamic>;
                  return ChatScreen(
                    label: map['label'],
                    chatRoomId: map['chatRoomId'],
                  );
                },
              ),
            ],
          ),
          // GoRoute(
          //   path: ScreenB.metaData['path'],
          //   name: ScreenB.metaData['path'],
          //   pageBuilder: (context, state) {
          //     return _pageAnimation(const ScreenB(), state, ref: ref);
          //   },
          //   routes: [
          //     GoRoute(
          //       path: DetailsScreen.path,
          //       parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
          //       builder: (context, state) {
          //         return const DetailsScreen(label: 'B');
          //       },
          //     ),
          //   ],
          // ),

          /// 通知
          GoRoute(
            path: NotificationScreen.metadata['path'],
            name: NotificationScreen.metadata['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(const NotificationScreen(), state, ref: ref);
            },
            routes: [
              GoRoute(
                path: ChatScreen.path,
                // name: nameは一意出なければならない
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  final map = state.extra as Map<String, dynamic>;
                  return ChatScreen(label: map['label'], chatRoomId: map['chatRoomId']);
                },
              ),
            ],
          ),

          /// HOME
          GoRoute(
            path: UserScreen.metaData['path'],
            name: UserScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(const UserScreen(), state, ref: ref);
            },
            routes: [
              GoRoute(
                path: LoginScreen.path,
                name: LoginScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const LoginScreen();
                },
              ),
              GoRoute(
                path: SignupScreen.path,
                name: SignupScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const SignupScreen();
                },
              ),
              GoRoute(
                path: AuthUpdateScreen.path,
                name: AuthUpdateScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const AuthUpdateScreen();
                },
              ),
            ],
          ),
        ],
      )
    ],
    redirect: (context, state) {
      final uri = state.uri.toString();

      // 画面リロードされたらパスと選択中のボトムアイコンに差異が生じるため
      if (bottomItems.map((e) => e['path']).contains(uri)) {
        final currentBottomMap = ref.read(currentBottomIndexProvider);
        currentBottomMap['index'] = bottomItems.indexWhere((e) => uri == e['path']);
      }

      if (uri.contains(ChatScreen.path) && state.extra == null) {
        return ChatThreadScreen.metaData['path'];
      }
      return null;
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
      Animation<Offset> offset = Tween(begin: start, end: Offset.zero).animate(animation);
      return SlideTransition(position: offset, child: child);
    },
    // transitionDuration: Duration(milliseconds: state.uri.toString() == '/chat' ? 500 : 300),
  );
}
