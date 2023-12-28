import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/chat/providers/bak/chat_message_list_provider.dart';
import 'package:programming_sns/features/chat/providers/bak/chat_user_list.dart';
// import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_message_event.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/features/event/realtime_event_provider.dart';
import 'package:programming_sns/features/theme/theme_color.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String label;
  final String chatRoomId;
  const ChatScreen({
    super.key,
    required this.label,
    required this.chatRoomId,
  });

  static const String path = 'chatScreen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  bool showReaction = true;

  bool isCurrentScreen = true;

  ChatController chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    chatUsers: [],
  );

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");

    return Scaffold(
        appBar: AppBar(title: Text(widget.label)),

        /// USER
        body: ref.watchEX(
          userModelProvider,
          complete: (currentUserModel) {
            final ChatUser currentChatUser = UserModel.toChatUser(currentUserModel);

            /// CHATUSER
            return ref.watchEX(chatUserListProvider(widget.chatRoomId), complete: (chatUserList) {
              /// CHAT

              return ref.watchEX(
                chatMessageListProvider(widget.chatRoomId),
                complete: (messageList) {
                  chatController.initialMessageList = messageList;
                  chatController.chatUsers = chatUserList;

                  ref.watch(chatMessageEventProvider(widget.chatRoomId));

                  return ChatView(
                    currentUser: currentChatUser,
                    chatController: chatController,
                    onSendTap: onSendTap,
                    featureActiveConfig: const FeatureActiveConfig(
                      enableSwipeToReply: !kIsWeb, // TODO
                      enableSwipeToSeeTime: false,
                      enablePagination: true, // ページネーション
                    ),

                    /// ページネーション
                    loadMoreData: () async {
                      final messageList = chatController.initialMessageList;

                      if (messageList.isEmpty) return;
                      final firstMessage =
                          ref.watch(firstChatMessageProvider(widget.chatRoomId)).value;

                      final isFirst = messageList.first.createdAt == firstMessage?.createdAt;

                      if (isFirst) return;

                      ref.watch(firstChatMessageProvider(widget.chatRoomId));

                      final messageList25Ago = await ref
                          .read(chatMessageListProvider(widget.chatRoomId).notifier)
                          .getMessageList(id: messageList.first.id)
                          .catchError((e) async {
                        chatController.scrollController
                            .jumpTo(chatController.scrollController.position.minScrollExtent);
                        return await showDialog(
                          context: ref.read(rootNavigatorKeyProvider).currentContext!,
                          builder: (_) => ErrorDialog(error: e),
                        );
                      });
                      print(messageList25Ago);
                      chatController.loadMoreData(messageList25Ago);
                    },

                    /// チャットの状態
                    chatViewState: ChatViewState.hasMessages,
                    // appBar: AppBar(
                    //   title: Text(widget.label),
                    // ),

                    /// TODO chat全体背景
                    chatBackgroundConfig: const ChatBackgroundConfiguration(
                      // messageTimeIconColor: theme.messageTimeIconColor,
                      // messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
                      // defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                      //   textStyle: TextStyle(
                      //     color: theme.chatHeaderColor,
                      //     fontSize: 17,
                      //   ),
                      // ),
                      backgroundColor: ThemeColor.weak, // 背景色(chat全体背景)
                    ),

                    /// (送信フォーム)
                    sendMessageConfig: SendMessageConfiguration(
                      allowRecordingVoice: false, // ボイスなし
                      imagePickerIconsConfig: const ImagePickerIconsConfiguration(
                        cameraImagePickerIcon: SizedBox(), // カメラなし
                      ),
                      replyMessageColor: Colors.black, // リプライメッセージの色(送信フォーム)
                      defaultSendButtonColor: ThemeColor.main, // 送信ボタン(送信フォーム)
                      replyDialogColor: ThemeColor.littleWeak, // リプライ背景色(送信フォーム)
                      replyTitleColor: ThemeColor.strong, // リプライタイトル(送信フォーム)

                      // textFieldBackgroundColor: Colors.grey.shade100, // 背景色
                      closeIconColor: theme.closeIconColor,
                      textFieldConfig: TextFieldConfiguration(
                        maxLines: 100, // 入力文字の行
                        contentPadding: const EdgeInsets.all(10),
                        hintText: '文字入れてね', // TODO ヒント
                        compositionThresholdTime: const Duration(seconds: 5),
                        textStyle: TextStyle(
                          color: theme.textFieldTextColor,
                        ),
                      ),
                    ),
                    // TODO わからん
                    chatBubbleConfig: ChatBubbleConfiguration(
                      onDoubleTap: (message) {
                        setState(() {
                          showReaction = !showReaction;
                        });
                      },
                      // TODO わからん
                      outgoingChatBubbleConfig: const ChatBubble(
                        receiptsWidgetConfig: ReceiptsWidgetConfig(
                          showReceiptsIn: ShowReceiptsIn.all, // チャット横幅
                        ),
                      ),
                    ),

                    messageConfig: MessageConfiguration(
                      customMessageBuilder: (p0) {
                        return ChatCard(
                          currentUser: currentChatUser,
                          showReaction: showReaction,
                          chatController: chatController,
                          message: p0,
                        );
                      },
                    ),
                    profileCircleConfig: const ProfileCircleConfiguration(
                      profileImageUrl: Data.profileImage,
                    ),

                    repliedMessageConfig: const RepliedMessageConfiguration(
                      backgroundColor: ThemeColor.strong,
                      verticalBarColor: ThemeColor.strong,
                      repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: ThemeColor.weak,
                        highlightScale: 1.1,
                      ),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                      replyTitleTextStyle: TextStyle(color: ThemeColor.strong),
                    ),

                    /// TODO スワイプ
                    swipeToReplyConfig: SwipeToReplyConfiguration(
                      replyIconColor: theme.swipeToReplyIconColor,
                    ),
                  );
                },
              );
            });
          },
        ));
  }

  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final user = ref.watch(userModelProvider).value;
    if (user == null) return;
    final msg = Message(
      // id: ID.unique(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: user.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
      chatRoomId: widget.chatRoomId,
    );
    await ref.read(messageAPIProvider).createMessageDocument(msg);

    // final chatController = ref.watch(chatControllerProvider(widget.chatRoomId)).value;
    // if (chatController != null && chatController.initialMessageList.length > 100) {
    //   chatController.initialMessageList =
    //       await ref.read(chatControllerProvider(widget.chatRoomId).notifier).getMessages();
    // }
  }
}
