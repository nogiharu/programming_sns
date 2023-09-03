import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/utils/markdown/custom_pre_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class ChatCard extends ConsumerWidget {
  const ChatCard({
    super.key,
    required this.currentUser,
    required this.showReaction,
    required this.message,
    required this.chatController,
  });

  final ChatUser currentUser;
  final bool showReaction;
  final ChatController chatController;
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO カスタムバブル
    final markdownRegex = RegExp(r'(\*{1,2}|_{1,2}|`{1,2}|~{1,2}|#{1,6})');

    RegExp regExp = RegExp(r"(http|www)[^\s]+[\w]");
    List<String?> urls = regExp.allMatches(message.message).map((match) => match.group(0)).toList();

    double webWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Column(
        crossAxisAlignment:
            message.sendBy == currentUser.id ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Wrap(
            direction: Axis.horizontal,
            alignment: message.sendBy == currentUser.id ? WrapAlignment.end : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              if (message.sendBy == currentUser.id)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    DateFormat.Hm('ja').format(message.createdAt),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(5),
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? webWidth / 1.5 : 250,
                  minWidth: 55,
                ),
                decoration: BoxDecoration(
                  color: message.sendBy == currentUser.id
                      ? Colors.amber.shade300
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft:
                        message.sendBy == currentUser.id ? const Radius.circular(20) : Radius.zero,
                    bottomRight:
                        message.sendBy == currentUser.id ? Radius.zero : const Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(1, 5),
                      color: Colors.grey,
                      blurRadius: 5,
                    ),
                  ],
                ),
                width: markdownRegex.hasMatch(message.message)
                    ? message.message.length.toDouble() * 22
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (markdownRegex.hasMatch(message.message))
                      Markdown(
                        builders: {
                          'pre': CustomPreBuilder(),
                        },
                        styleSheet: MarkdownStyleSheet(
                          textScaleFactor: kIsWeb ? 1.4 : null,
                        ),
                        padding: const EdgeInsets.all(5),
                        selectable: true,
                        data: message.message,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // スクロール
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          message.message,
                          style: kIsWeb ? const TextStyle(fontSize: 18) : null,
                        ),
                      ),
                    if (urls.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: message.sendBy == currentUser.id
                              ? const Radius.circular(20)
                              : Radius.zero,
                          bottomRight: message.sendBy == currentUser.id
                              ? Radius.zero
                              : const Radius.circular(20),
                        ),
                        child: AnyLinkPreview(
                          link: urls[0]!,
                          borderRadius: 0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              if (message.sendBy != currentUser.id)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    DateFormat.Hm('ja').format(message.createdAt),
                  ),
                ),
            ],
          ),
          if (message.reaction.reactions.isNotEmpty && showReaction)
            Align(
              alignment:
                  message.sendBy == currentUser.id ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey.shade300,
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: message.reaction.reactions.toSet().map((e) {
                    final reactionMap = groupBy(message.reaction.reactions, (p0) => p0).map(
                      (key, value) => MapEntry(
                        key,
                        value.length > 1 ? '$key${value.length}' : key,
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        onTap: () {
                          print('ああああああ');
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 500,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: ListView.builder(
                                  itemCount: message.reaction.reactions.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(chatController
                                              .getUserFromId(message.reaction.reactedUserIds[index])
                                              .profilePhoto!),
                                        ),
                                        title: Text(
                                          chatController
                                              .getUserFromId(message.reaction.reactedUserIds[index])
                                              .name,
                                        ),
                                        trailing: Text(message.reaction.reactions[index]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }, // なぜかカーソルポインタが変化しないため無視。
                        child: IgnorePointer(
                          child: Text(reactionMap[e]!),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
