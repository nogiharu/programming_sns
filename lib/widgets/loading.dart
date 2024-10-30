import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>(
  (ref) => false,
);

class Loading extends ConsumerWidget {
  const Loading({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child!,
        // ローディングを表示する
        if (ref.watch(loadingProvider))
          const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
