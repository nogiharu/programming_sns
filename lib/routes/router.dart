import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/scaffold_with_navbar.dart';
import 'package:programming_sns/features/auth/screens/login_credentials_update_screen.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/chat/screens/chat_screen2.dart';
import 'package:programming_sns/features/chat/screens/chat_thread_screen.dart';
import 'package:programming_sns/features/user/screens/home_screen.dart';

import 'package:programming_sns/temp/tempScreen.dart';

final rootNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'root'),
);
final shellNavigatorKeyProvider = Provider(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
);

final router = Provider((ref) {
  // タブの順番
  final bottomItems = [
    ChatThreadScreen.metaData,
    ScreenB.metaData,
    HomeScreen.metaData,
  ];

  return GoRouter(
    navigatorKey: ref.read(rootNavigatorKeyProvider),
    initialLocation: bottomItems.first['path'],
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
          /// CHAT
          GoRoute(
            path: ChatThreadScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const ChatThreadScreen(),
                state,
                ref: ref,
              );
            },
            routes: [
              GoRoute(
                path: ChatScreen.path,
                name: ChatScreen.path,
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
              GoRoute(
                path: ChatScreen2.path,
                name: ChatScreen2.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  return const ChatScreen2(
                    label: 'AAAA',
                    chatRoomId: '658624a57c74937e4ec7',
                  );
                },
              ),
            ],
          ),

          /// HOME
          GoRoute(
            path: HomeScreen.metaData['path'],
            name: HomeScreen.metaData['path'],
            pageBuilder: (context, state) {
              return _pageAnimation(
                const HomeScreen(),
                state,
                ref: ref,
              );
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
                path: LoginCredentialsUpdateScreen.path,
                name: LoginCredentialsUpdateScreen.path,
                parentNavigatorKey: ref.read(rootNavigatorKeyProvider),
                builder: (context, state) {
                  final map = state.extra as Map<String, dynamic>;
                  return LoginCredentialsUpdateScreen(
                    label: map['label'],
                    isIdUpdate: map['isIdUpdate'],
                  );
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

      // ログイン情報更新画面でリロードされたらextraがnullになる
      if (uri.contains(LoginCredentialsUpdateScreen.path) && state.extra == null) {
        return HomeScreen.metaData['path'];
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
