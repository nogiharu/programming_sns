import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/features/chat/widgets/reaction_widget.dart';
import 'package:intl/intl.dart';
import 'package:any_link_preview/any_link_preview.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    super.key,
    required this.currentUser,
    required this.message,
    required this.chatController,
    required this.isLast,
  });

  final ChatUser currentUser;
  final ChatController chatController;
  final Message message;
  final bool isLast;

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

    return GestureDetector(
      onDoubleTap: () => setState(() => isShowReaction = !isShowReaction),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: isSendByCurrentUser ? WrapAlignment.end : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: BoxConstraints(
              maxWidth: webWidth / 1.2,
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
                MarkdownBuilder(
                  message: widget.message.message,
                  chatUsers: widget.chatController.chatUsers,
                  currenUser: widget.currentUser,
                ),

                // リンクプレビュー
                if (urlMatches.isNotEmpty)
                  // if (urlMatches.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: !isSendByCurrentUser ? const Radius.circular(20) : Radius.zero,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: AnyLinkPreview(
                        link: urlMatches.first!,
                        proxyUrl: 'https://cors-anywhere.herokuapp.com/',
                        headers: const {
                          'Access-Control-Allow-Origin': '*',
                        },
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
          Row(
            mainAxisAlignment:
                isSendByCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (widget.message.reaction.reactions.isNotEmpty && isShowReaction)
                ReactionWidget(
                  reaction: widget.message.reaction,
                  chatController: widget.chatController,
                ),
              if (!isSendByCurrentUser || (isSendByCurrentUser && !widget.isLast))
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Tooltip(
                    message: '長押しするとリアクションできるよ(*^^*)',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Text(
                      DateFormat.MMMd('ja').format(widget.message.createdAt) +
                          DateFormat.Hm('ja').format(widget.message.createdAt),
                      style: TextStyle(
                        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 0) - 6.0,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
