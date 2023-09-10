import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/controller/chat_controller2.dart';
import 'package:programming_sns/features/chat/controller/message_provider.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/models/user_model.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';

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
  // ChatControllerNotifier get chatControllerNotifier => ref.read(chatControllerProvider.notifier);
  // ChatController get chatController => ref.read(chatControllerProvider.notifier).chatController;

  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  bool showReaction = true;

  ChatController chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    chatUsers: [],
  );

  String currentUserId = '';

  @override
  void initState() {
    super.initState();

    // ref.read(chatControllerProvider2.notifier).initScrollController();

    chatController.scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");

    return Scaffold(

        /// USER
        body: ref.watchEX(
      userModelProvider,
      complete: (currentUserModel) {
        final ChatUser currentChatUser = UserModel.toChatUser(currentUserModel);
        // currentUserId = currentUserModel.id;

        /// CHAT
        return ref.watchEX(
          chatMessagesAndChatUsersProvider,
          complete: (chatList) {
            // final chatController = ref.read(chatControllerProvider2.notifier).initializeController(
            //       chatList.$1,
            //       chatList.$2,
            //     );

            // final chatControllerNotifier = ref.read(chatControllerProvider2.notifier);

            // ref.watch(realtimeMessageProvider).when(
            //       data: (message) {
            //         if (message.sendBy != currentUserModel.id) {
            //           chatController.addMessage(message);
            //           // chatList.$1.add(message);
            //           // chatController.addMessage(message);
            //         }
            //         // chatList.$1.add(message);
            //       },
            //       error: (error, stackTrace) {},
            //       loading: () {},
            //     );
            chatController.initialMessageList = chatList.$1;
            chatController.chatUsers = chatList.$2;

            return ChatView(
              currentUser: currentChatUser,
              chatController: chatController,
              onSendTap: onSendTap,
              featureActiveConfig: const FeatureActiveConfig(
                enableSwipeToReply: !kIsWeb, // TODO
                enableSwipeToSeeTime: false,
              ),
              chatViewState: ChatViewState.hasMessages,
              appBar: AppBar(
                title: const Text('AppBar'),
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
                backgroundColor: Colors.amber.shade100,
              ),
              sendMessageConfig: SendMessageConfiguration(
                allowRecordingVoice: false, // ボイスなし
                imagePickerIconsConfig: const ImagePickerIconsConfiguration(
                  cameraImagePickerIcon: SizedBox(), // カメラなし
                ),
                replyMessageColor: theme.replyMessageColor,
                defaultSendButtonColor: Colors.amber,
                replyDialogColor: Colors.amber.shade200, // リプライ背景色
                replyTitleColor: Colors.amber.shade900,

                textFieldBackgroundColor: Colors.grey.shade100, // 背景色
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
                  // setState(() {
                  //   showReaction = !showReaction;
                  // });
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

              repliedMessageConfig: RepliedMessageConfiguration(
                backgroundColor: Colors.amber,
                verticalBarColor: Colors.amber,
                repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                  enableHighlightRepliedMsg: true,
                  highlightColor: Colors.amber.shade100,
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
            );
          },
        );
      },
    ));
  }

  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final user = ref.watch(userModelProvider).value;

    if (user == null) return;
    final msg = Message(
      id: ID.unique(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: user.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
    );
    print('IIIIII');
    // if (currentUserId == '') return;
    ref.read(messageAPIProvider).createMessageDocument(msg);
    // chatController.addMessage(MessageEX.fromMap(doc.data));
  }
}
