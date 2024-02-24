import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/features/chat/widgets/reaction_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:any_link_preview/any_link_preview.dart';
// import 'package:programming_sns/utils/markdown/markdown_builder.dart';

// import 'package:chatview/src/widgets/reaction_widget.dart' as chatview;

class ChatCard extends StatefulWidget {
  const ChatCard({
    super.key,
    required this.currentUser,
    required this.message,
    required this.chatController,
  });

  final ChatUser currentUser;
  final ChatController chatController;
  final Message message;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  bool isShowReaction = true;

  @override
  Widget build(BuildContext context) {
    final urlRegExp = RegExp(
      r"(^|\s+)(http[s]?:\/\/[^\s]+)",
      caseSensitive: false, // 大文字小文字を区別しない
    );

    final urlMatches = urlRegExp.allMatches(widget.message.message).map((match) {
      return match.group(2);
    }).toList();

    double webWidth = MediaQuery.of(context).size.width;

    final isSendByCurrentUser = widget.message.sendBy == widget.currentUser.id;

    // 時間
    final timeWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          const Tooltip(
            message: 'ここを長押しするとリアクションできるよ(*^^*)',
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(
              Icons.help_outline_sharp,
              size: 15,
            ),
          ),
          Text(
            DateFormat.Hm('ja').format(widget.message.createdAt),
          ),
        ],
      ),
    );

    return GestureDetector(
      onDoubleTap: () => setState(() => isShowReaction = !isShowReaction),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: isSendByCurrentUser ? WrapAlignment.end : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (isSendByCurrentUser)
            // 時間
            timeWidget,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? webWidth / 1.5 : 250,
              minWidth: 55,
            ),
            decoration: BoxDecoration(
              color: isSendByCurrentUser ? Colors.amber.shade300 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)).copyWith(
                bottomLeft: isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: !isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(1, 5),
                  color: Colors.grey,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Markdown
                MarkdownBuilder(message: widget.message.message),

                // リンクプレビュー
                if (!kIsWeb && urlMatches.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: !isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: AnyLinkPreview(
                        link: urlMatches.first!,
                        borderRadius: 0,
                        errorWidget: Container(
                          color: Colors.grey[200],
                          child: const Center(child: Text('エラーが発生しました(´；ω；`)')),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isSendByCurrentUser) timeWidget,
          if (widget.message.reaction.reactions.isNotEmpty && isShowReaction)
            Align(
              alignment: isSendByCurrentUser ? Alignment.bottomRight : Alignment.bottomLeft,
              child: ReactionWidget(
                reaction: widget.message.reaction,
                chatController: widget.chatController,
              ),
              //     chatview.ReactionWidget(
              //   isMessageBySender: isSendByCurrentUser,
              //   reaction: widget.message.reaction,
              //   // messageReactionConfig: messageReactionConfig,
              // ),
            ),
        ],
      ),
    );
  }
}
