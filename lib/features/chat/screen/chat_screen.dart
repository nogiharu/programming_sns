import 'package:any_link_preview/any_link_preview.dart';
import 'package:chatview/chatview.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/features/auth/controller/auth_controller.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';
import 'package:programming_sns/utils/markdown/custom_pre_builder.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const Map<String, dynamic> metaData = {
    'path': '/chat',
    'label': 'チャット',
    'icon': Icon(Icons.chat),
    'index': 3,
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  final currentUser = ChatUser(
    id: '1',
    name: 'Flutter',
    profilePhoto: Data.profileImage,
  );
  final _chatController = ChatController(
    initialMessageList: Data.messageList,
    scrollController: ScrollController(),
    chatUsers: [
      ChatUser(
        id: '2',
        name: 'Simform',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '3',
        name: 'Jhon',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '4',
        name: 'Mike',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '5',
        name: 'Rich',
        profilePhoto: Data.profileImage,
      ),
    ],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  bool showReaction = true;
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");

    return Scaffold(
      body: ChatView(
        currentUser: currentUser,
        chatController: _chatController,
        onSendTap: _onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          enableSwipeToReply: !kIsWeb, // TODO
        ),
        chatViewState: ChatViewState.hasMessages,
        appBar: ChatViewAppBar(
          elevation: theme.elevation,
          backGroundColor: theme.appBarColor,
          profilePicture: Data.profileImage,
          backArrowColor: theme.backArrowColor,
          chatTitle: "Chat view",
          chatTitleTextStyle: TextStyle(
            color: theme.appBarTitleTextStyle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
          userStatus: "online",
          userStatusTextStyle: const TextStyle(color: Colors.grey),
          actions: [
            IconButton(
              onPressed: _onThemeIconTap,
              icon: Icon(
                isDarkTheme ? Icons.brightness_4_outlined : Icons.dark_mode_outlined,
                color: theme.themeIconColor,
              ),
            ),
            IconButton(
              tooltip: 'Toggle TypingIndicator',
              onPressed: _showHideTypingIndicator,
              icon: Icon(
                Icons.keyboard,
                color: theme.themeIconColor,
              ),
            ),
          ],
        ),

        /// TODO chat全体背景
        chatBackgroundConfig: ChatBackgroundConfiguration(
          messageTimeIconColor: theme.messageTimeIconColor,
          messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(
              color: theme.chatHeaderColor,
              fontSize: 17,
            ),
          ),
          backgroundColor: theme.backgroundColor,
        ),
        sendMessageConfig: SendMessageConfiguration(
          allowRecordingVoice: false, // ボイスなし
          imagePickerIconsConfig: const ImagePickerIconsConfiguration(
            cameraImagePickerIcon: SizedBox(), // カメラなし
          ),
          replyMessageColor: theme.replyMessageColor,
          defaultSendButtonColor: theme.sendButtonColor,
          replyDialogColor: theme.replyDialogColor,
          replyTitleColor: Colors.amber,

          textFieldBackgroundColor: Colors.grey.shade100,
          closeIconColor: theme.closeIconColor,
          textFieldConfig: TextFieldConfiguration(
            maxLines: 100, // 入力文字の行
            contentPadding: const EdgeInsets.all(10),
            hintText: '文字入れてね', // TODO ヒント
            // compositionThresholdTime: const Duration(seconds: 1),
            textStyle: TextStyle(
              color: theme.textFieldTextColor,
            ),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          onDoubleTap: (message) {
            setState(() {
              showReaction = !showReaction;
            });
          },
          outgoingChatBubbleConfig: const ChatBubble(
            receiptsWidgetConfig: ReceiptsWidgetConfig(
              showReceiptsIn: ShowReceiptsIn.all, // チャット横幅
            ),
          ),
        ),

        messageConfig: MessageConfiguration(
          customMessageBuilder: (p0) {
            // TODO カスタムバブル
            final markdownRegex = RegExp(r'(\*{1,2}|_{1,2}|`{1,2}|~{1,2}|#{1,6})');

            RegExp regExp = RegExp(r"(http|www)[^\s]+[\w]");
            List<String?> urls =
                regExp.allMatches(p0.message).map((match) => match.group(0)).toList();

            double webWidth = MediaQuery.of(context).size.width;

            return SelectionArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: p0.sendBy == currentUser.id
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (p0.sendBy == currentUser.id)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            DateFormat.Hm('ja').format(p0.createdAt),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? webWidth / 1.5 : 250,
                          minWidth: 55,
                        ),
                        decoration: BoxDecoration(
                          color: p0.sendBy == currentUser.id
                              ? Colors.amber.shade300
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: p0.sendBy == currentUser.id
                                ? const Radius.circular(20)
                                : Radius.zero,
                            bottomRight: p0.sendBy == currentUser.id
                                ? Radius.zero
                                : const Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(1, 5),
                              color: Colors.grey,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        width: markdownRegex.hasMatch(p0.message)
                            ? p0.message.length.toDouble() * 22
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (markdownRegex.hasMatch(p0.message))
                              Markdown(
                                builders: {
                                  'pre': CustomPreBuilder(),
                                },
                                styleSheet: MarkdownStyleSheet(
                                  textScaleFactor: kIsWeb ? 1.4 : null,
                                ),
                                padding: const EdgeInsets.all(5),
                                selectable: true,
                                data: p0.message,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(), // スクロール
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  p0.message,
                                  style: kIsWeb ? const TextStyle(fontSize: 18) : null,
                                ),
                              ),
                            if (urls.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: p0.sendBy == currentUser.id
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                  bottomRight: p0.sendBy == currentUser.id
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
                      if (p0.sendBy != currentUser.id)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            DateFormat.Hm('ja').format(p0.createdAt),
                          ),
                        ),
                    ],
                  ),
                  if (p0.reaction.reactions.isNotEmpty && showReaction)
                    Align(
                      alignment: p0.sendBy == currentUser.id
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: p0.reaction.reactions.toSet().map((e) {
                            final reactionMap = groupBy(p0.reaction.reactions, (p0) => p0).map(
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
                                          itemCount: p0.reaction.reactions.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(_chatController
                                                      .getUserFromId(
                                                          p0.reaction.reactedUserIds[index])
                                                      .profilePhoto!),
                                                ),
                                                title: Text(
                                                  _chatController
                                                      .getUserFromId(
                                                          p0.reaction.reactedUserIds[index])
                                                      .name,
                                                ),
                                                trailing: Text(p0.reaction.reactions[index]),
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
          },
        ),
        profileCircleConfig: const ProfileCircleConfiguration(
          profileImageUrl: Data.profileImage,
        ),

        repliedMessageConfig: RepliedMessageConfiguration(
          backgroundColor: theme.repliedMessageColor,
          verticalBarColor: theme.verticalBarColor,
          repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
            enableHighlightRepliedMsg: true,
            highlightColor: Colors.pinkAccent.shade100,
            highlightScale: 1.1,
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.25,
          ),
          replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
        ),

        /// TODO スワイプ
        swipeToReplyConfig: SwipeToReplyConfiguration(
          replyIconColor: theme.swipeToReplyIconColor,
        ),
      ),
    );
  }

  Future<void> _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    final id = int.parse(Data.messageList.last.id) + 1;

    final msg = Message(
      id: id.toString(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: currentUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
      // title: '',
    );

    print('MAPだよ');
    print(msg.toMap());

    _chatController.addMessage(msg);

    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
