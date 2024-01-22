// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:markdown_widget/config/configs.dart';
// import 'package:markdown_widget/widget/all.dart';
// import 'package:markdown_widget/widget/blocks/leaf/code_block.dart';
// import 'package:markdown_widget/widget/blocks/leaf/link.dart';
// import 'package:markdown_widget/widget/markdown_block.dart';
// import 'package:programming_sns/utils/markdown/code_wrapper.dart';

// class MarkdownBuilder extends StatelessWidget {
//   final String message;

//   const MarkdownBuilder({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final markdownConfig = isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

//     const textStyle = TextStyle(fontSize: kIsWeb ? null : 10);

//     final preConfig = isDark
//         ? PreConfig.darkConfig.copy(
//             textStyle: textStyle,
//             styleNotMatched: textStyle.copyWith(color: Colors.white),
//             wrapper: (child, code, language) => CodeWrapperWidget(child, code, language),
//             padding: const EdgeInsets.all(10).copyWith(top: kIsWeb ? 10 : 33),
//           )
//         : const PreConfig().copy(
//             textStyle: textStyle,
//             styleNotMatched: textStyle,
//             wrapper: (child, code, language) => CodeWrapperWidget(child, code, language),
//             padding: const EdgeInsets.all(10).copyWith(top: kIsWeb ? 10 : 33),
//           );

//     final linkConfig = const LinkConfig()..style.copyWith(fontSize: kIsWeb ? null : 10);

//     return MarkdownBlock(
//       data: message,
//       config: markdownConfig.copy(configs: [preConfig, linkConfig]),
//     );
//   }
// }
