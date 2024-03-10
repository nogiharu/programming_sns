import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/markdown_builder.dart';
import 'package:chatview/src/widgets/chat_view_inherited_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MarkdownInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final Widget child;

  final ValueNotifier<String>? inputText;

  const MarkdownInput({
    Key? key,
    required this.textEditingController,
    required this.child,
    this.inputText,
  }) : super(key: key);

  @override
  State<MarkdownInput> createState() => _MarkdownInputState();
}

class _MarkdownInputState extends State<MarkdownInput> {
  bool isInput = true;

  late List<ChatUser> chatUsers;

  @override
  void initState() {
    super.initState();

    widget.textEditingController.addListener(() {
      if (widget.textEditingController.text.isNotEmpty) {
        // こうしないとアイコンボタンクリック時にimageアイコン→sendアイコンにならない
        widget.inputText?.value += 'これ何'; // これ何
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // コンストラクタのリレーになるため　TODO どうすればいいか
    final chatController = ChatViewInheritedWidget.of(context)?.chatController;
    final currentUser = ChatViewInheritedWidget.of(context)?.currentUser;

    chatUsers =
        chatController?.chatUsers.where((chatUser) => chatUser.id != currentUser?.id).toList() ??
            [];

    return Wrap(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 入力、プレビュー、リセット
              Row(
                children: [
                  textButtonWidget(
                    text: '入力',
                    onPressed: () {
                      if (!isInput) setState(() => isInput = true);
                    },
                    color: isInput ? Colors.white : null,
                  ),
                  textButtonWidget(
                    text: 'プレビュー',
                    onPressed: () {
                      if (isInput && widget.textEditingController.text.isNotEmpty) {
                        setState(() => isInput = false);
                      }
                    },
                    color: !isInput ? Colors.white : null,
                  ),
                  textButtonWidget(
                    text: 'リセット',
                    onPressed: () {
                      widget.textEditingController.text = '';
                    },
                  ),
                ],
              ),

              if (isInput)
                // アイコン一覧
                Row(
                  children: [
                    // FlutterMentions()
                    iconButtonWidget(
                      iconData: Icons.alternate_email_sharp,
                      markdownText: '@',
                      onPressed: mentionDropdownButton,
                    ),
                    iconButtonWidget(iconData: Icons.code, markdownText: '`java`'),
                    iconButtonWidget(
                      iconData: Icons.source,
                      markdownText: '''
```java
throw new NullPointerException("Hello, World");
```
''',
                    ),
                    iconButtonWidget(iconData: Icons.format_list_bulleted, markdownText: '- 箇条書き'),
                    iconButtonWidget(iconData: Icons.h_mobiledata, markdownText: '### 見出し'),
                    iconButtonWidget(iconData: Icons.format_bold, markdownText: '**太字**'),
                    iconButtonWidget(
                      iconData: Icons.link,
                      markdownText: '[文字](https://www.google.com)',
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (isInput)
          widget.child
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 10, left: 10),
            child: MarkdownBuilder(
              message: widget.textEditingController.text,
              chatUsers: chatUsers,
            ),
          ),
      ],
    );
  }

  Widget textButtonWidget({required String text, required VoidCallback onPressed, Color? color}) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(5),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 13),
        ),
      ),
    );
  }

  Widget iconButtonWidget(
      {required IconData iconData, required String markdownText, VoidCallback? onPressed}) {
    return IconButton(
      // mobileしか効かない
      style: IconButton.styleFrom(
        padding: const EdgeInsets.only(right: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      padding: const EdgeInsets.only(right: 5), // webしか効かない
      constraints: const BoxConstraints(), // webしか効かない
      onPressed: onPressed ?? () => widget.textEditingController.text += markdownText,
      icon: Icon(iconData),
      iconSize: 20,
    );
  }

  Future<void> mentionDropdownButton() async {
    if (chatUsers.isEmpty) return;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // TODO 全員できるようにしたい
    // final menntionNameList = chatUsers.map((e) => e.name).toList()..insert(0, '全員');

    final selectedChatUser = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width, // left,
        overlay.size.height, // top,
        0, // right,
        0, // bottom
      ),
      items: List.generate(
        chatUsers.length,
        (index) => PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          value: chatUsers[index],
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: chatUsers[index].name),
                TextSpan(
                  text: '@${chatUsers[index].userId}',
                  style: const TextStyle(color: Colors.blue, fontSize: 13),
                )
              ],
            ),
          ),
          // Text(chatUsers[index].name),
        ),
      ),
    );

    if (selectedChatUser != null) {
      final text = widget.textEditingController.text;
      final toMentionName = '${selectedChatUser.name}@${selectedChatUser.userId}';
      widget.textEditingController.text += '${text.isEmpty ? '' : ' '}$toMentionName \n';
    }
  }
}
