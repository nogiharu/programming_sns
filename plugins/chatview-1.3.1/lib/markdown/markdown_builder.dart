import 'package:chatview/markdown/code_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';

class MarkdownBuilder extends StatelessWidget {
  final String message;
  final Color? pTextColor;

  const MarkdownBuilder({
    super.key,
    required this.message,
    this.pTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // 全角始まり、改行一回始まり（半角始まり、改行2回以上始まりは除外）
    RegExp regex = RegExp(r'(?:(?:(?:(?!\n\n).)+\n)|　)(https?://\S+)');

    String replacedMessage = message;
    regex.allMatches(message).forEach((match) {
      replacedMessage = message.replaceAll(match.group(1).toString(), ' ${match.group(1)}');
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
    final pConfig = PConfig(textStyle: TextStyle(color: pTextColor, fontSize: mobileFontSize));

    return MarkdownBlock(
      data: replacedMessage,
      config: markdownConfig.copy(configs: [
        preConfig,
        pConfig,
      ]),
    );
  }
}
