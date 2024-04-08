import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final currentBottomIndexProvider = Provider<Map<String, int>>((_) => {
      'index': 0,
      'preIndex': 0,
    });

// class ScaffoldWithNavbar extends ConsumerStatefulWidget {
//   const ScaffoldWithNavbar({
//     super.key,
//     required this.child,
//     required this.bottomItems,
//   });
//   final Widget child;
//   final List<Map<String, dynamic>> bottomItems;

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ScaffoldWithNavbarState();
// }

// class _ScaffoldWithNavbarState extends ConsumerState<ScaffoldWithNavbar> {
//   // @override
//   // void initState() {
//   //   super.initState();

//   //   if (ref.watch(notificationListProvider).value != null) {
//   //     ref.watch(notificationListProvider).value;
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: (widget.child as HeroControllerScope).child,
//       bottomNavigationBar: BottomNavigationBar(
//         selectedItemColor: Theme.of(context).primaryColor,
//         backgroundColor: Colors.white,
//         selectedIconTheme: IconThemeData(
//           color: Theme.of(context).primaryColor,
//         ),
//         unselectedItemColor: Colors.grey,
//         // unselectedLabelStyle: const TextStyle(color: Colors.grey),
//         items: ref.watch(notificationListProvider).when(
//           data: (data) {
//             return widget.bottomItems.map((meta) {
//               if (meta['label'] == '通知') {
//                 meta['icon'] = badges.Badge(
//                   position: badges.BadgePosition.topEnd(top: -15),
//                   badgeStyle: badges.BadgeStyle(
//                     padding: const EdgeInsets.all(6),
//                     badgeColor: Colors.amber.shade800,
//                   ),
//                   badgeContent:
//                       Text(data.length.toString(), style: const TextStyle(color: Colors.white)),
//                   child: const Icon(Icons.notifications),
//                 );
//               }
//               return BottomNavigationBarItem(
//                 icon: meta['icon'],
//                 label: meta['label'],
//               );
//             }).toList();
//           },
//           error: (e, _) {
//             return widget.bottomItems
//                 .map(
//                   (meta) => BottomNavigationBarItem(
//                     icon: meta['icon'],
//                     label: meta['label'],
//                   ),
//                 )
//                 .toList();
//           },
//           loading: () {
//             return widget.bottomItems
//                 .map(
//                   (meta) => BottomNavigationBarItem(
//                     icon: meta['icon'],
//                     label: meta['label'],
//                   ),
//                 )
//                 .toList();
//           },
//         ),
//         currentIndex: ref.watch(currentBottomIndexProvider)['index']!,
//         onTap: (index) {
//           // ref.watch(aaa.notifier).state += 1;
//           print(ref.watch(aaa));
//           // widget.bottomItems.forEach((element) {
//           //   if (element['icon'] is badges.Badge) {
//           //     print((element['icon'] as badges.Badge).badgeContent);
//           //     element['icon'] = badges.Badge(
//           //       position: badges.BadgePosition.topEnd(top: -15),
//           //       badgeStyle: badges.BadgeStyle(
//           //         padding: const EdgeInsets.all(6),
//           //         badgeColor: Colors.amber.shade800,
//           //       ),
//           //       badgeContent:
//           //           Text(ref.watch(aaa).toString(), style: const TextStyle(color: Colors.white)),
//           //       child: const Icon(Icons.notifications),
//           //     );
//           //   }
//           // });
//           final currentBottomMap = ref.read(currentBottomIndexProvider);

//           currentBottomMap['preIndex'] = currentBottomMap['index']!;
//           currentBottomMap['index'] = index;
//           context.go(widget.bottomItems[index]['path']);
//         },
//       ),
//     );
//   }
// }

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
    // ボトムアイテム
    final iconLabelItems = ref.watch(notificationListProvider).maybeWhen(
          data: (data) => bottomItems.map((meta) {
            if (meta['label'] == '通知') {
              meta['icon'] = NotificationScreen.getIconBadge(
                  notificationCount: data.where((e) => !e.isRead).length);
            }
            return BottomNavigationBarItem(icon: meta['icon'], label: meta['label']);
          }).toList(),
          orElse: () => bottomItems
              .map((meta) => BottomNavigationBarItem(icon: meta['icon'], label: meta['label']))
              .toList(),
        );

    return Scaffold(
      body: (child as HeroControllerScope).child,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        unselectedItemColor: Colors.grey,
        // unselectedLabelStyle: const TextStyle(color: Colors.grey),
        items: iconLabelItems,
        currentIndex: ref.watch(currentBottomIndexProvider)['index']!,
        onTap: (index) {
          final currentBottomMap = ref.read(currentBottomIndexProvider);

          currentBottomMap['preIndex'] = currentBottomMap['index']!;
          currentBottomMap['index'] = index;
          context.go(bottomItems[index]['path']);
        },
      ),
    );
  }
}
