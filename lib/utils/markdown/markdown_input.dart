// import 'package:chatview/markdown/markdown_builder.dart';
// import 'package:flutter/material.dart';

// class MarkdownInput extends StatefulWidget {
//   final TextEditingController textEditingController;
//   final Widget child;

//   final ValueNotifier<String>? inputText;

//   const MarkdownInput({
//     Key? key,
//     required this.textEditingController,
//     required this.child,
//     this.inputText,
//   }) : super(key: key);

//   @override
//   State<MarkdownInput> createState() => _MarkdownInputState();
// }

// class _MarkdownInputState extends State<MarkdownInput> {
//   bool isInput = true;

//   @override
//   void initState() {
//     super.initState();

//     widget.textEditingController.addListener(() {
//       if (widget.textEditingController.text.isNotEmpty) {
//         // こうしないとアイコンボタンクリック時にimageアイコン→sendアイコンにならない
//         widget.inputText?.value += 'これ何'; // これ何
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: [
//         Container(
//           width: double.infinity,
//           color: Colors.grey.shade200,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       color: isInput ? Colors.white : null,
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                       child: TextButton(
//                         child: const Text(
//                           '入力',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                         onPressed: () {
//                           if (!isInput) setState(() => isInput = true);
//                         },
//                       ),
//                     ),
//                     Container(
//                       color: !isInput ? Colors.white : null,
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                       child: TextButton(
//                         child: const Text(
//                           'プレビュー',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                         onPressed: () {
//                           if (isInput && widget.textEditingController.text.isNotEmpty) {
//                             setState(() => isInput = false);
//                           }
//                         },
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                       child: TextButton(
//                         child: const Text(
//                           'リセット',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                         onPressed: () {
//                           widget.textEditingController.text = '';
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (isInput)
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => widget.textEditingController.text += '`java`',
//                         icon: const Icon(Icons.code),
//                       ),
//                       IconButton(
//                         onPressed: () => widget.textEditingController.text += '''
// ```java
// throw new NullPointerException("Hello, World");
// ```
// ''',
//                         icon: const Icon(Icons.source),
//                       ),
//                       IconButton(
//                         onPressed: () => widget.textEditingController.text += '- 箇条書き',
//                         icon: const Icon(Icons.format_list_bulleted),
//                       ),
//                       IconButton(
//                         onPressed: () => widget.textEditingController.text += '### 見出し',
//                         icon: const Icon(Icons.h_mobiledata),
//                       ),
//                       IconButton(
//                         onPressed: () => widget.textEditingController.text += '**太字**',
//                         icon: const Icon(Icons.format_bold),
//                       ),
//                       IconButton(
//                         onPressed: () =>
//                             widget.textEditingController.text += '[文字](https://www.google.com)',
//                         icon: const Icon(Icons.link),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//         if (isInput)
//           widget.child
//         else
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 10, left: 10),
//             child: MarkdownBuilder(message: widget.textEditingController.text),
//           ),
//       ],
//     );
//   }
// }
