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
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade300,
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
                child: Text(reactionMap[e]!),
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
      builder: (context) {
        return Container(
          height: 500,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: ListView.builder(
            itemCount: reaction.reactions.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      chatController
                          .getUserFromId(
                            reaction.reactedUserIds[index],
                          )
                          .profilePhoto!,
                    ),
                  ),
                  title: Text(
                    chatController.getUserFromId(reaction.reactedUserIds[index]).name,
                  ),
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
