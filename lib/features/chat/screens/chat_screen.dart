import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_message_event.dart';
import 'package:programming_sns/features/chat/providers/chat_room_provider.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/features/theme/theme_color.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:programming_sns/utils/markdown/markdown_builder.dart';

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

  late ChatController _chatController;

  late ChatUser _currentChatUser;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");

    return Scaffold(
        appBar: AppBar(title: Text(widget.label)),

        /// USER
        body: ref.watchEX(
          userModelProvider,
          complete: (currentUserModel) {
            _currentChatUser = UserModel.toChatUser(currentUserModel);

            /// CHAT
            return ref.watchEX(
              chatControllerProvider(widget.chatRoomId),
              complete: (chatController) {
                /// EVENT
                ref.watch(chatMessageEventProvider(widget.chatRoomId));

                _chatController = chatController;
                return ChatView(
                  currentUser: _currentChatUser,
                  chatController: _chatController,
                  onSendTap: onSendTap,
                  featureActiveConfig: const FeatureActiveConfig(
                    enableSwipeToReply: !kIsWeb, // TODO
                    enableSwipeToSeeTime: false,
                    enablePagination: true, // ページネーション
                  ),
                  // loadingWidget: const SizedBox(height: 0),

                  /// ページネーション
                  loadMoreData: loadMoreData,

                  /// チャットの状態
                  chatViewState: ChatViewState.hasMessages,

                  /// TODO chat全体背景
                  chatBackgroundConfig: const ChatBackgroundConfiguration(
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
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.zero,
                      maxLines: 100, // 入力文字の行
                      contentPadding: const EdgeInsets.all(10),
                      hintText: '文字入れてね(*^_^*)', // TODO ヒント
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
                        // showReaction = !showReaction;
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
                    customMessageBuilder: (message) {
                      return ChatCard(
                        currentUser: _currentChatUser,
                        chatController: _chatController,
                        message: message,
                      );
                    },
                    // 画像 TODO
                    imageMessageConfig: ImageMessageConfiguration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      height: kIsWeb ? 200 : null,
                      width: kIsWeb ? 200 : null,
                      shareIconConfig: ShareIconConfiguration(
                        defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                        defaultIconColor: theme.shareIconColor,
                        onPressed: (p0) {
                          // TODO アイコンたっぷ
                        },
                      ),
                      onTap: (url) {
                        // TODO 画像たっぷ
                        print(url);
                        print('ああ');
                      },
                    ),
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
          },
        ));
  }

  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final msg = Message(
      createdAt: DateTime.now(),
      message: message,
      sendBy: _currentChatUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
      chatRoomId: widget.chatRoomId,
    );

    await ref.read(chatControllerProvider(widget.chatRoomId).notifier).createMessage(msg);

    final chatRoom = ref.read(chatRoomProvider.notifier).getChatRoom(widget.chatRoomId);
    ref
        .read(chatRoomAPIProvider)
        .updateChatRoomDocument(chatRoom.copyWith(updatedAt: DateTime.now()));

    if (_chatController.initialMessageList.length > 100) {
      _chatController.initialMessageList =
          await ref.read(chatControllerProvider(widget.chatRoomId).notifier).getMessages();
    }
  }

  Future<void> loadMoreData() async {
    if (_chatController.initialMessageList.isEmpty) return;

    final firstMessage = ref.watch(firstChatMessageProvider(widget.chatRoomId)).value;

    final isFirst = _chatController.initialMessageList.first.createdAt == firstMessage?.createdAt;

    if (isFirst) return;

    final messageList25Ago = await ref
        .read(chatControllerProvider(widget.chatRoomId).notifier)
        .getMessages(id: _chatController.initialMessageList.first.id);

    _chatController.loadMoreData(messageList25Ago);
  }
}
