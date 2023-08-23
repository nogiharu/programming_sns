import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CustomPreBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    // print(text.text);
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: SelectableText(
              text.text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final data = ClipboardData(text: text.text); // 2行を追加
            Clipboard.setData(data);
          },
          tooltip: 'クリップボードにコピー',
          icon: const Icon(
            Icons.content_copy_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
