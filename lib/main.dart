import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/theme/theme_color.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境
  const envFile = String.fromEnvironment('env');
  await dotenv.load(fileName: envFile);

  await Supabase.initialize(
    url: dotenv.env[kReleaseMode ? 'SUPABASE_URL' : 'LOCAL_SUPABASE_URL'] ?? '',
    anonKey: dotenv.env[kReleaseMode ? 'SUPABASE_ANON_KEY' : 'LOCAL_SUPABASE_ANON_KEY'] ?? '',
  );

  // urlの#を消す
  usePathUrlStrategy();

  runApp(
    const ProviderScope(
      child: Main(),
    ),
  );
}

class Main extends ConsumerWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: ThemeData(
        // アプバー
        appBarTheme: const AppBarTheme(color: ThemeColor.main),
        // プライマリーカラー
        primaryColor: ThemeColor.main,
        // テキストボタン
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(ThemeColor.strong),
          ),
        ),
        // エレベイテッドボタン
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(ThemeColor.main),
            foregroundColor: const WidgetStatePropertyAll(Colors.black),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        // テキストフィールドの縦棒
        textSelectionTheme: const TextSelectionThemeData(cursorColor: ThemeColor.main),
        // インジケータ
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: ThemeColor.main),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(router),
      scaffoldMessengerKey: ref.read(scaffoldMessengerKeyProvider),
    );
  }
}
