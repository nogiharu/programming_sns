import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/at_mention_paragraph_node.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/core/enums.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notifications_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:programming_sns/theme/theme_color.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';
import 'package:async/async.dart';
import 'package:url_launcher/url_launcher.dart';

/// FIXME 適当に作ったから消します。
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
  // AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  bool _isKeyboardVisible = false;

  ChatController _chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    chatUsers: [],
  );

  late ChatUser _currentChatUser;

  late final ChatControllerNotifier _chatControllerNotifier =
      ref.read(chatControllerProvider(widget.chatRoomId).notifier);

  late final TextEditingController? _textEditingController =
      ref.read(_chatControllerNotifier.textEditingProvider)[widget.chatRoomId];

  Message? updateMessage;

  CancelableOperation? _initMentionScrollCancel;

  late ChatRoomModel chatRoomModel;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("ja");
    ref.read(_chatControllerNotifier.textEditingProvider)[widget.chatRoomId] ??=
        TextEditingController();
    WidgetsBinding.instance.endOfFrame.then((_) async {
      await onMentionMessageReaded();
    });
    // 現在のチャットルーム取得(ソートに使用)
    chatRoomModel = ref.read(chatRoomsProvider).value!.firstWhere((e) => e.id == widget.chatRoomId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery でキーボードの表示状態を監視
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // キーボードの状態が変わったときにのみ処理を実行
    if (_isKeyboardVisible != isKeyboardVisible) {
      if (!isKeyboardVisible) {
        // キーボードが閉じた場合
        FocusScope.of(context).unfocus();
      }
      _isKeyboardVisible = isKeyboardVisible;
    }

    WidgetsBinding.instance.endOfFrame.then((_) async {
      final isNotEmpty = _chatController.initialMessageList.isNotEmpty;
      final isMention = ref.read(notificationsProvider.notifier).mentionCreatedAt != null;
      if (isNotEmpty && isMention) {
        initMentionScroll();
      }
    });

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.label),
        leading: IconButton(
          onPressed: () {
            // ウィジェットが破棄される際に、非同期処理が完了していない場合は強制的に完了させる
            if (_initMentionScrollCancel != null) {
              _initMentionScrollCancel!.cancel();
              ref.read(notificationsProvider.notifier).mentionCreatedAt = null;
            }
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
      ),

      /// USER
      body: ref.watchEX(
        userProvider,
        complete: (currentUserModel) {
          ref.watch(notificationsProvider);
          _currentChatUser = UserModel.toChatUser(currentUserModel);

          return ref.watchEX(
            chatControllerProvider(widget.chatRoomId),
            complete: (chatController) {
              _chatController = chatController;
              return ChatView(
                onChatListTap: () {
                  // FocusScope.of(context).unfocus();
                },
                currentUser: _currentChatUser,
                chatController: _chatController,
                onSendTap: onSendTap,
                featureActiveConfig: const FeatureActiveConfig(
                  enableSwipeToReply: false, // スワイプ
                  enableSwipeToSeeTime: false,
                  enablePagination: true, // ページネーション
                  // enableDoubleTapToLike: true, // TODO ダブルタップ
                ),

                /// ページネーション
                loadMoreData: loadMoreData,

                /// チャットの状態
                chatViewState: ChatViewState.hasMessages,

                /// TODO chat全体背景
                chatBackgroundConfig: const ChatBackgroundConfiguration(
                  backgroundColor: ThemeColor.weak, // 背景色(chat全体背景)
                  // height: height,
                ),
                // 追加
                textEditingController: _textEditingController!,

                /// (送信フォーム)
                sendMessageConfig: SendMessageConfiguration(
                  allowRecordingVoice: false, // ボイスなし
                  enableCameraImagePicker: false, // カメラなし
                  imagePickerConfiguration: ImagePickerConfiguration(
                    // 画像送信
                    onImagePicked: uploadImagedWrapper,
                  ),
                  replyMessageColor: Colors.black, // リプライメッセージの色(送信フォーム)
                  defaultSendButtonColor: ThemeColor.main, // 送信ボタン(送信フォーム)
                  replyDialogColor: ThemeColor.littleWeak, // リプライ背景色(送信フォーム)
                  replyTitleColor: ThemeColor.strong, // リプライタイトル(送信フォーム)

                  // textFieldBackgroundColor: Colors.grey.shade100, // 背景色
                  // closeIconColor: theme.closeIconColor,
                  textFieldConfig: const TextFieldConfiguration(
                    padding: EdgeInsets.zero,
                    // margin: EdgeInsets.zero,
                    borderRadius: BorderRadius.zero,
                    maxLines: 100, // 入力文字の行
                    contentPadding: EdgeInsets.all(10),
                    hintText: '文字入れてね(*^_^*)', // TODO ヒント
                    compositionThresholdTime: Duration(seconds: 5),
                    textStyle: TextStyle(
                        // color: theme.textFieldTextColor,
                        ),
                    textCapitalization: TextCapitalization.none, // フォーマットしない
                    textInputType: TextInputType.multiline, // 改行サポート
                  ),
                  // 編集フラグ
                  isSendReplyUpdateMessage: updateMessage != null,
                  // 編集閉じる
                  closeReplyUpdateMessage: () {
                    updateMessage = null;
                    _textEditingController!.clear();
                  },
                ),
                // TODO わからん
                chatBubbleConfig: ChatBubbleConfiguration(
                    onDoubleTap: (message) {
                      // これ入れないとハートになる　ChatBubbleWidget → 337行目
                      setState(() {});
                    },
                    // TODO わからん
                    outgoingChatBubbleConfig: const ChatBubble(
                      receiptsWidgetConfig: ReceiptsWidgetConfig(
                        showReceiptsIn: ShowReceiptsIn.all, // チャット横幅
                      ),
                    ),
                    inComingChatBubbleConfig: const ChatBubble(senderNameTextStyle: TextStyle())),

                messageConfig: MessageConfiguration(
                  customMessageBuilder: (message) {
                    final isLast = message.id == _chatController.initialMessageList.last.id;

                    if (message.isDeleted ?? false) {
                      return Text(
                        '削除されました',
                        style: TextStyle(color: Colors.grey.shade500),
                      );
                    }

                    return ChatCard(
                      currentUser: _currentChatUser,
                      chatController: _chatController,
                      message: message,
                      isLast: isLast,
                    );
                  },
                  // 画像 TODO
                  imageMessageConfig: ImageMessageConfiguration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    height: kIsWeb ? 200 : null,
                    width: kIsWeb ? 200 : null,
                    shareIconConfig: ShareIconConfiguration(
                      // defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                      // defaultIconColor: theme.shareIconColor,
                      onPressed: downloadImagedWrapper,
                    ),
                    onTap: (url) async {
                      await previewImage(url: url, context: context);
                    },
                  ),
                ),
                profileCircleConfig: ProfileCircleConfiguration(
                  // profileImageUrl: Data.profileImage,
                  bottomPadding: 22, // アバターの下

                  onAvatarTap: (p0) {
                    print(p0); // プロフィール画像タップ
                  },
                ),
                reactionPopupConfig: ReactionPopupConfiguration(
                  // 絵文字リアクション
                  userReactionCallback: (message, emoji) async {
                    await _chatControllerNotifier.upsertState(message);
                  },
                ),
                replyPopupConfig: ReplyPopupConfiguration(
                  // メッセージ編集
                  onUpdateTap: (message) {
                    _textEditingController!.text = message.message;
                    setState(() {
                      updateMessage = message;
                    });
                  },
                  // メッセージ削除
                  onDeleteTap: (message) async {
                    await _chatControllerNotifier.upsertState(message.copyWith(isDeleted: true));
                  },
                  // メッセージコピー
                  onCopyTap: (message) async {
                    if (message.messageType.isImage) return;
                    await Clipboard.setData(ClipboardData(text: message.message));
                  },
                ),

                repliedMessageConfig: const RepliedMessageConfiguration(
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
                swipeToReplyConfig: const SwipeToReplyConfiguration(
                    // replyIconColor: theme.swipeToReplyIconColor,
                    ),
              );
            },
          );
        },
      ),
    );
  }

  /// 送信 or 更新
  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    if (message.trim().isEmpty || updateMessage?.message == message) return;

    final currentTime = DateTime.now();

    final msg = Message(
      id: updateMessage?.id,
      createdAt: updateMessage?.createdAt ?? currentTime,
      message: message,
      sendBy: _currentChatUser.id,
      replyMessage: updateMessage?.replyMessage ?? replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType,
      chatRoomId: widget.chatRoomId,
      updatedAt: currentTime,
    );
    await _chatControllerNotifier.upsertState(msg);

    updateMessage = null;

    // 【メンション】　awaitはしない
    onSendMention(message: message, currentTime: currentTime);

    // スクロールが100件超えていたら25件にリセット
    // if (_chatController.initialMessageList.length > 100) {
    //   _chatController.initialMessageList = await _chatControllerNotifier.getMessages();
    // }
  }

  /// ページング
  /// 25件ずつ取得
  Future<void> loadMoreData() async {
    // 空、または一番最初のメッセージがすでに表示されていたらページングしない
    final isFirst = _chatController.initialMessageList.first.id == _chatControllerNotifier.firstId;
    if (_chatController.initialMessageList.isEmpty || isFirst) return;

    final nextMessages = await _chatControllerNotifier.getNextMessages();

    _chatController.loadMoreData(nextMessages);
  }

  /// メンション通知
  /// UPDATE時にリレーションシップを組めない
  Future<void> onSendMention({required String message, required DateTime currentTime}) async {
    // @を除去
    final mentionUserIds = AtMentionParagraphNode.splitText(message)
        .where((e) => e.startsWith('@'))
        .map((e) => e.replaceAll('@', '').trim());

    if (mentionUserIds.isEmpty) return;

    // 現在のチャットユーザのユーザIDと等しいものがある場合、ドキュメントIDリストにする
    final chatUsers = _chatController.chatUsers.where((chatUser) => mentionUserIds.any(
          (mentionUserId) =>
              chatUser.mentionId == mentionUserId && _currentChatUser.mentionId != mentionUserId,
        ));

    await Future.forEach(chatUsers, (chatUser) async {
      final notification = NotificationModel.instance(
        chatRoomId: widget.chatRoomId,
        chatRoomName: widget.label,
        userId: chatUser.id,
        message: message,
        notificationType: NotificationType.mention,
        sendByUserName: _currentChatUser.name,
        createdAt: currentTime.toUtc(),
      );

      await ref.read(notificationsProvider.notifier).upsertState(notification);
    });
  }

  void initMentionScroll() {
    _initMentionScrollCancel =
        CancelableOperation.fromFuture(Future.delayed(const Duration(milliseconds: 500), () async {
      final notificationsNotifier = ref.read(notificationsProvider.notifier);
      if (notificationsNotifier.mentionCreatedAt == null) return;

      final mentionMessageLocation = getMessageLocation(notificationsNotifier.mentionCreatedAt!);

      if (mentionMessageLocation == null) {
        await loadMoreData();
        initMentionScroll();
        return;
      }

      final screenHeight = MediaQuery.of(context).size.height;

      final offset = (mentionMessageLocation as RenderBox).localToGlobal(Offset.zero);
      // MarkdownInputの高さは大体200
      final scrollOffset = screenHeight - offset.dy - 200;

      await _chatController.scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      notificationsNotifier.mentionCreatedAt = null;
    }));
  }

  Future<void> onMentionMessageReaded() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final notifications = ref.watch(notificationsProvider).value;

    if (notifications == null) return;

    await Future.forEach(notifications, (notification) async {
      if (notification.chatRoomId == widget.chatRoomId && !notification.isRead) {
        final isFoundMessage = getMessageLocation(notification.createdAt) != null;

        if (isFoundMessage) {
          // 既読にする
          await ref
              .read(notificationsProvider.notifier)
              .upsertState(notification.copyWith(isRead: true));
        }
      }
    });
  }

  RenderObject? getMessageLocation(DateTime mentionCreatedAt) {
    return _chatController.initialMessageList
        .firstWhereOrNull((e) => mentionCreatedAt == e.createdAt)
        ?.key
        .currentContext
        ?.findRenderObject();
  }

  /// 画像ダウンロード
  Future<void> downloadImagedWrapper(String url) async {
    await _chatControllerNotifier.asyncGuardWrapper(() async {
      await downloadImage(url);
    });
  }

  /// 画像アップロード
  Future<String?> uploadImagedWrapper(XFile? xFile) async {
    String? imagePath;
    await _chatControllerNotifier.asyncGuardWrapper(() async {
      imagePath = await uploadImage('messages/${widget.chatRoomId}/', xFile: xFile);
    });
    return imagePath;
  }
}
