import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/apis/storage_api_provider.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/utils/utils.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_message_event_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_room_provider.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/theme/theme_color.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

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
    if (ref.read(textEditingControllerProvider)[widget.chatRoomId] == null) {
      ref.read(textEditingControllerProvider)[widget.chatRoomId] = TextEditingController();
    }
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
                    // enableSwipeToReply: !kIsWeb, // TODO
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
                    // height: 500,
                    // width: 300,
                  ),
                  // 追加
                  textEditingController:
                      ref.read(textEditingControllerProvider)[widget.chatRoomId]!,

                  /// (送信フォーム)
                  sendMessageConfig: SendMessageConfiguration(
                    allowRecordingVoice: false, // ボイスなし
                    enableCameraImagePicker: false, // カメラなし
                    imagePickerConfiguration: ImagePickerConfiguration(
                      // 画像送信
                      onImagePicked: uploadImage,
                    ),
                    replyMessageColor: Colors.black, // リプライメッセージの色(送信フォーム)
                    defaultSendButtonColor: ThemeColor.main, // 送信ボタン(送信フォーム)
                    replyDialogColor: ThemeColor.littleWeak, // リプライ背景色(送信フォーム)
                    replyTitleColor: ThemeColor.strong, // リプライタイトル(送信フォーム)

                    // textFieldBackgroundColor: Colors.grey.shade100, // 背景色
                    closeIconColor: theme.closeIconColor,
                    textFieldConfig: TextFieldConfiguration(
                      padding: EdgeInsets.zero,
                      // margin: EdgeInsets.zero,
                      borderRadius: BorderRadius.zero,
                      maxLines: 100, // 入力文字の行
                      contentPadding: const EdgeInsets.all(10),
                      hintText: '文字入れてね(*^_^*)', // TODO ヒント
                      compositionThresholdTime: const Duration(seconds: 5),
                      textStyle: TextStyle(
                        color: theme.textFieldTextColor,
                      ),
                      textCapitalization: TextCapitalization.none, // フォーマットしない
                    ),
                  ),
                  // TODO わからん
                  chatBubbleConfig: ChatBubbleConfiguration(
                    onDoubleTap: (message) {
                      // これ入れないとハートになる　ChatBubbleWidget → 337行目
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
                        onPressed: downloadImage,
                      ),
                      onTap: previewImage,
                    ),
                  ),
                  profileCircleConfig: ProfileCircleConfiguration(
                    profileImageUrl: Data.profileImage,
                    onAvatarTap: (p0) {
                      print(p0); // プロフィール画像タップ
                    },
                  ),
                  reactionPopupConfig: ReactionPopupConfiguration(
                    userReactionCallback: (message, emoji) async {
                      await ref
                          .read(messageAPIProvider)
                          .updateMessageDocument(message)
                          .catchError(ref.read(showDialogProvider));
                      print(message);
                      print(emoji);
                    },
                  ),
                  replyPopupConfig: ReplyPopupConfiguration(
                    onUnsendTap: (message) async {
                      print(message);
                    },
                    onMoreTap: () async {
                      print('あああ');
                    },
                  ),

                  repliedMessageConfig: const RepliedMessageConfiguration(
                    // repliedMessageWidgetBuilder: (replyMessage) {
                    //   // print(replyMessage.message);
                    //   // return MarkdownBuilder(message: replyMessage!.message);
                    //   return const Text('text');
                    // },
                    backgroundColor: ThemeColor.strong,
                    verticalBarColor: ThemeColor.strong,
                    repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                      enableHighlightRepliedMsg: true,
                      enableScrollToRepliedMsg: true, // リプライタップ時のスクロール
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

  /// 送信
  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    if (message.trim().isEmpty) return;
    final msg = Message(
      createdAt: DateTime.now(),
      message: message,
      sendBy: _currentChatUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
      chatRoomId: widget.chatRoomId,
    );

    // メッセージ送信
    await ref.read(chatControllerProvider(widget.chatRoomId).notifier).createMessage(msg);

    // チャットルーム取得
    final chatRoom = ref.read(chatRoomProvider.notifier).getChatRoom(widget.chatRoomId);
    // チャットルームの日付更新
    ref
        .read(chatRoomAPIProvider)
        .updateChatRoomDocument(chatRoom.copyWith(updatedAt: DateTime.now()));

    // スクロールが100件超えていたら25件にリセット
    if (_chatController.initialMessageList.length > 100) {
      _chatController.initialMessageList =
          await ref.read(chatControllerProvider(widget.chatRoomId).notifier).getMessages();
    }
  }

  /// ページング
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

  /// 画像ダウンロード
  Future<void> downloadImage(String url) async {
    final isSaved = await ref
        .read(storageAPIProvider)
        .downloadImage(url, AppwriteConstants.messageImagesBucket)
        .catchError(ref.read(showDialogProvider));

    if (isSaved) ref.read(snackBarProvider('${kIsWeb ? 'ダウンロード' : '写真'}に保存完了したよ(*^_^*)'));
  }

  /// 画像アップロード
  Future<String?> uploadImage(XFile? xFile) async {
    String? imagePath = xFile?.path;
    if (xFile != null) {
      imagePath = await ref
          .read(storageAPIProvider)
          .uploadImage(
            xFile,
            AppwriteConstants.messageImagesBucket,
          )
          .catchError(ref.read(showDialogProvider));
    }
    return imagePath;
  }

  /// 画像プレビュー
  Future<void> previewImage(String url) async {
    print(ref.read(textEditingControllerProvider)[widget.chatRoomId]?.text);
    final uint8List = await ref
        .read(storageAPIProvider)
        .previewImgae(
          url,
          AppwriteConstants.messageImagesBucket,
        )
        .catchError(ref.read(showDialogProvider));

    await showDialog(
      barrierDismissible: true,
      context: ref.read(rootNavigatorKeyProvider).currentContext!,
      builder: (context) {
        return GestureDetector(
          onTap: () => context.pop(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.1,
                maxScale: 5,
                child: Image.memory(
                  uint8List,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
