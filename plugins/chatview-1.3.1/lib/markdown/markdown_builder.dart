import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/at_mention_paragraph_node.dart';
import 'package:chatview/markdown/code_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/all.dart';

class MarkdownBuilder extends StatelessWidget {
  final String message;
  final Color? pTextColor;
  final List<ChatUser>? chatUsers;

  const MarkdownBuilder({
    super.key,
    required this.message,
    this.pTextColor,
    this.chatUsers,
  });

  @override
  Widget build(BuildContext context) {
    // (改行以外の文字が1回以上で改行で終わる | 全角スペース)かつ('https'または'http'と'://'と空白以外の文字が1回以上続く)
    // ※前半のキャプチャグループで半角スペースを考慮していない理由
    // MarkdownBlockでリンクの先頭に半角スペースがあればリンクになるため、あえて入れていない
    RegExp regex = RegExp(r'([^\n]+\n|　)(https?://\S+)');

    String replacedMessage = message;
    regex.allMatches(message).forEach((match) {
      // 改行後のhttps文字列の頭に半角スペースを入れないとリンクにならない
      replacedMessage = message.replaceAll(match.group(2).toString(), ' ${match.group(2)}');
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final markdownConfig = isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

    const textStyle = TextStyle(fontSize: kIsWeb ? null : 10);

    final preConfig = isDark
        ? PreConfig.darkConfig.copy(
            textStyle: textStyle,
            styleNotMatched: textStyle.copyWith(color: Colors.white),
            wrapper: (child, code, language) => CodeWrapperWidget(child, code, language),
          )
        : const PreConfig().copy(
            textStyle: textStyle,
            styleNotMatched: textStyle,
            wrapper: (child, code, language) => CodeWrapperWidget(child, code, language),
          );

    double? mobileFontSize; // FIXME共通化したい
    if (kIsWeb) mobileFontSize = MediaQuery.of(context).size.width < 400 ? 13 : 16;
    final pConfig = PConfig(
        textStyle: TextStyle(
      color: pTextColor,
      // fontSize: mobileFontSize,
      fontSize: 16,
    ));

    final codeConfig = CodeConfig(style: const CodeConfig().style.copyWith(fontSize: 16));

    List<String> mentionIdList = [];
    if (chatUsers != null) {
      mentionIdList = List.generate(chatUsers!.length, (index) => chatUsers![index].userId!);
    }

    return MarkdownBlock(
      data: replacedMessage,
      config: markdownConfig.copy(configs: [
        preConfig,
        pConfig,
        codeConfig,
      ]),
      generator: MarkdownGenerator(generators: [
        SpanNodeGeneratorWithTag(
            tag: MarkdownTag.p.name,
            generator: (e, config, visitor) {
              return AtMentionParagraphNode(
                pConfig: config.p,
                mentionIdList: mentionIdList,
              );
            }),
      ]),
    );
  }
}
