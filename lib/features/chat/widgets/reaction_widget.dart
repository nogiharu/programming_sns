import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

/// TODO safariだとバグる
class ReactionWidget extends StatelessWidget {
  final Reaction reaction;
  final ChatController chatController;

  const ReactionWidget({
    super.key,
    required this.reaction,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade300,
      ),
      padding: const EdgeInsets.all(5),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: reaction.reactions.toSet().map((e) {
          final reactionMap = groupBy(reaction.reactions, (data) => data).map(
            (key, value) => MapEntry(
              key,
              value.length > 1 ? '$key${value.length}' : key,
            ),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () => _showReactionBottomSheet(context),
              // なぜかカーソルポインタが変化しないため無視。
              child: IgnorePointer(
                child: Text(reactionMap[e] ?? ''),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showReactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      constraints: const BoxConstraints.expand(width: double.infinity),
      builder: (context) {
        return Container(
          height: 500,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: ListView.builder(
            itemCount: reaction.reactions.length,
            itemBuilder: (context, index) {
              final chatUser = chatController.chatUsers
                  .firstWhereOrNull((e) => e.id == reaction.reactedUserIds[index]);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chatUser?.profilePhoto ?? ''),
                  ),
                  title: Text(chatUser?.name ?? ''),
                  trailing: Text(reaction.reactions[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
