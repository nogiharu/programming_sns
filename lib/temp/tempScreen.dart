import 'package:chatview/markdown/code_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:any_link_preview/any_link_preview.dart';
// import 'package:markdown/markdown.dart' as md;
// import 'package:programming_sns/utils/markdown/custom_pre_builder.dart';
import 'package:markdown_widget/markdown_widget.dart';

// import 'package:programming_sns/utils/markdown/code_wrapper.dart';
// AtMarkPGenerator
class AtMentionParagraphNode extends ElementNode {
  final String text;

  AtMentionParagraphNode({required this.text});

  /// @で始まり(直後が@で始まっていない)空白以外の文字が1回以上続き[スペースまたは改行の一文字]で終わる
  /// (?!@)はキャプチャグループだが、否定先読み（つまり除外）なので、match.group(0)で全体をとる
  // RegExp regex = RegExp(r'@(?!@)\S+[\s\n]');
  // RegExp regex = RegExp(r'@(?!@)[^\s@]+[\s\n]|[\s\n]$');
  // RegExp regex = RegExp(r'@(?!@)[^\s@]+(?=[\s\n]|$)|[\s\n]$');
  /// (行の先頭|)　@で始まり(直後が@で始まっていない)空白以外の文字が1回以上続き[スペースまたは改行の一文字]で終わる
  RegExp regex = RegExp(r'(^|\s)@(?!@)[^\s@]+(?=[\s\n]|$)');

  List<String> splitText(String input) {
    List<String> result = [];
    int currentIndex = 0;

    // 正規表現に一致する部分を順番に処理
    regex.allMatches(input).forEach((RegExpMatch match) {
      // マッチの開始位置が現在のインデックスより後ろにあれば、その手前の非マッチ部分をリストに追加
      final isNoneMatch = currentIndex < match.start;
      if (isNoneMatch) result.add(input.substring(currentIndex, match.start));

      // マッチした部分をリストに追加
      result.add(match.group(0)!);

      // 現在のインデックスを更新
      currentIndex = match.end;
    });

    // 最後の正規表現のマッチ以降の部分をリストに追加
    final isLastNoneMatch = currentIndex < input.length;
    if (isLastNoneMatch) result.add(input.substring(currentIndex));

    return result;
  }

  @override
  void accept(SpanNode? node) {
    if (node is TextNode) {
      final textList = splitText(node.text);
      print(node.text);
      print(textList);

      textList.forEach((text) => super.accept(
            TextNode(
              text: text,
              style: TextStyle(color: text.startsWith(regex) ? Colors.blue : null),
            ),
          ));
    } else {
      super.accept(node);
    }
  }
}

class ScreenB extends ConsumerStatefulWidget {
  const ScreenB({super.key});
  static const Map<String, dynamic> metaData = {
    'path': '/b',
    'label': 'スクリーンB',
    'icon': Icon(Icons.business),
    'index': 1,
  };

  final String text3 = '''

```dart
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownPage extends StatelessWidget {
  final String data;

  MarkdownPage(this.data);

  @override
  Widget build(BuildContext context) => Scaffold(body: buildMarkdown());

  Widget buildMarkdown() => MarkdownWidget(data: data);
}
```

''';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenRefreshState();
}

class _ScreenRefreshState extends ConsumerState<ScreenB> {
  Widget buildMarkdown(BuildContext context) {
    final isDark = Theme.of(context).brightness != Brightness.dark;
    final config = isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    codeWrapper(child, text, language) => CodeWrapperWidget(child, text, language);
    return MarkdownBlock(
      data: widget.text3,
      config: isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    String text1 = '''
Markdown is the **best**!

* It has lists.
* It has [links](https://dart.dev).
* It has...
  ```dart
  void sourceCode() {}
  ```
* ...and _so much more_...

''';

    String text2 = '''
```dart
class ChatRoomScreen extends ConsumerWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watchEX(
      userModelProvider,
      complete: (userModel) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('text'),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              const ListTile();
              return null;
            },
          ),
        );
      },
    );
  }
}
```



''';
    final controller = TextEditingController();
    const sports = <String>[
      'football',
      'baseball',
      'tennis',
      'swimming',
    ];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Any Link Preview'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return sports.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String value) {
                  // Called when an option is selected
                  print('$valueを選択しました！');
                  setState(() {
                    controller.text = value; // Update the text field with the selected value
                  });
                },
              ),
              const MarkdownBlock(
                data: '''
 a@alaa @aaああ sss
 aaa sss@ @s @pp　@ssss@s @ssss@@aaa @@a　@p @ooo@
''',
              ),
              const SizedBox(
                height: 10,
                width: 90,
              ),
              const MarkdownBlock(
                  data:
                      'aaa https://www.youtube.com/watch?v=DDajl7kgiNY&list=PLT0aFqMLFiVUTdjjz84MgLJurDB417Vrx&index=25 aa'),
              MarkdownBlock(
                data: text2,
                config: MarkdownConfig(configs: [
                  // font
                  const PreConfig(
                    textStyle: TextStyle(fontSize: 10),
                    styleNotMatched: TextStyle(fontSize: 10),
                  ),
                ]),
              ),
              MarkdownBlock(data: text1, config: MarkdownConfig.defaultConfig.copy(configs: [])),
              MarkdownBlock(
                data: text2,
                config: MarkdownConfig.darkConfig.copy(
                  configs: [
                    PreConfig.darkConfig
                        .copy(styleNotMatched: const TextStyle(color: Colors.white, fontSize: 5))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenM extends ConsumerWidget {
  const ScreenM({super.key});
  // static const String path = '/b';
  static const Map<String, dynamic> metaData = {
    'path': '/b',
    'label': 'スクリーンB',
    'icon': Icon(Icons.business),
    'index': 1,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = [
      Container(
        color: Colors.amber,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.black,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        // width: 100,
        height: 100,
      ),
    ];
    return RefreshIndicator(
        onRefresh: () async {
          return Future.delayed(
            const Duration(seconds: 3),
          );
        },
        child: ref.watchEX(
          userModelProvider,
          complete: (p0) {
            return ListView.builder(
              itemCount: a.length,
              itemBuilder: (context, index) {
                return a[index];
              },
            );
          },
        ));

    return ref.watchEX(
      authProvider,
      complete: (_) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    //  await userService.signIn();
                    //  context.go(ScreenB.id);
                  },
                  child: const Text('ログイン'),
                ),
                const Text('Screen B'),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/b/details');
                  },
                  child: const Text('View B details'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ScreenC extends ConsumerWidget {
  const ScreenC({super.key});
  // static const String path = '/b';
  static const Map<String, dynamic> metaData = {
    'path': '/c',
    'label': 'スクリーンC',
    'icon': Icon(Icons.chat),
    'index': 3,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                //  await userService.signIn();
                //  context.go(ScreenB.id);
              },
              child: const Text('ログイン'),
            ),
            const Text('Screen C'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/b/details');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({
    required this.label,
    super.key,
  });
  static const String path = 'details';
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Details for $label',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/a/details/details2');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen2 extends ConsumerWidget {
  const DetailsScreen2({
    required this.label,
    super.key,
  });
  static const String path = 'details2';
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen2'),
      ),
      body: Center(
        child: Text(
          'Details for $label',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
