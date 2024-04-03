// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';

class AtMentionParagraphNode extends ElementNode {
  // final String text;
  final PConfig pConfig;
  final List<String> mentionIdList;
  AtMentionParagraphNode({
    // required this.text,
    required this.pConfig,
    required this.mentionIdList,
  });

  /// @で始まり(直後が@で始まっていない)空白以外の文字が1回以上続き[スペースまたは改行の一文字]で終わる

  /// (行の先頭|空白文字)で始まり、かつ@を含み(直後が@で始まっていない)かつ[空白と@以外の文字]が1回以上続き
  /// ([スペースまたは改行の一文字]|行の末尾)である　※先読みしないと末尾を判定してくれない
  // static RegExp regex = RegExp(r'(^|\s)@(?!@)[^\s@]+(?=[\s\n]|$)');
  static RegExp regex = RegExp(r'@(?!@)[^\s@]+(?=[\s\n]|$)');

  static List<String> splitText(
    String input,
  ) {
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

  /// MarkdownBlockのテキストの追加方法をカスタム
  /// メンションされたPタグをハイライト
  @override
  void accept(SpanNode? node) {
    if (node is TextNode) {
      final textList = splitText(node.text);

      textList.forEach((text) {
        bool isAtMention = text.startsWith(regex);
        if (mentionIdList.isNotEmpty) {
          isAtMention =
              mentionIdList.any((id) => text.replaceAll('@', '').trim() == id) && isAtMention;
        }

        final textStyle = pConfig.textStyle.copyWith(
          color: isAtMention ? Colors.blue : null,
          fontSize: isAtMention ? 13 : null,
        );

        super.accept(
          TextNode(
            text: text,
            style: textStyle,
          ),
        );
      });
    } else {
      super.accept(node);
    }
  }
}
