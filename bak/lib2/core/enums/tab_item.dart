import 'package:flutter/material.dart';
import '../../../lib2/features/home/screen/home_screen.dart';

import '../../temp/tempScreen.dart';

enum TabItem {
  screenA(
    icon: Icon(Icons.person),
    label: 'スクリーンA',
    path: ScreenA.path,
  ),
  screenB(
    icon: Icon(Icons.business),
    label: 'スクリーンB',
    path: ScreenB.path,
  ),
  home(
    icon: Icon(Icons.home),
    label: 'ホーム',
    path: HomeScreen.path,
  );

  const TabItem({
    required this.label,
    required this.icon,
    required this.path,
  });

  /// アイコン
  final Icon icon;

  /// タイトル
  final String label;

  /// 画面パス
  final String path;
}
