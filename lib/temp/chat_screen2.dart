import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_room_list_provider.dart';
import 'package:programming_sns/features/chat/widgets/chat_card.dart';
import 'package:programming_sns/temp/chat_card2.dart';

import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/temp/data2.dart';
import 'package:programming_sns/temp/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatScreen2 extends ConsumerStatefulWidget {
  final String label;
  final String chatRoomId;
  const ChatScreen2({
    super.key,
    required this.label,
    required this.chatRoomId,
  });

  static const String path = 'chatScreen2';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen2> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  bool showReaction = true;

  // late ChatController _chatController ;
  // late ChatUser _currentChatUser;
  final currentUser = ChatUser(
    id: '1',
    name: 'Flutter',
    profilePhoto: Data.profileImage,
  );

  late ChatUser _currentChatUser;
  late ChatController _chatController2;
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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");
    return Scaffold(
        appBar: AppBar(title: Text(widget.label)),
        body: ref.watchEX(
          userProvider,
          complete: (currentUserModel) {
            _currentChatUser = UserModel.toChatUser(currentUserModel);

            return ChatView(
              currentUser: _currentChatUser,
              chatController: _chatController,
              onSendTap: _onSendTap,
              featureActiveConfig: const FeatureActiveConfig(
                lastSeenAgoBuilderVisibility: true,
                receiptsBuilderVisibility: true,
              ),
              chatViewState: ChatViewState.hasMessages,
              chatViewStateConfig: ChatViewStateConfiguration(
                loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                  loadingIndicatorColor: theme.outgoingChatBubbleColor,
                ),
                onReloadButtonTap: () {},
              ),
              textEditingController: TextEditingController(),
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
                    onPressed: () {},
                    icon: Icon(
                      Icons.keyboard,
                      color: theme.themeIconColor,
                    ),
                  ),
                ],
              ),
              typeIndicatorConfig: TypeIndicatorConfiguration(
                flashingCircleBrightColor: theme.flashingCircleBrightColor,
                flashingCircleDarkColor: theme.flashingCircleDarkColor,
              ),
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
                imagePickerIconsConfig: ImagePickerIconsConfiguration(
                  cameraIconColor: theme.cameraIconColor,
                  galleryIconColor: theme.galleryIconColor,
                ),
                replyMessageColor: theme.replyMessageColor,
                defaultSendButtonColor: theme.sendButtonColor,
                replyDialogColor: theme.replyDialogColor,
                replyTitleColor: theme.replyTitleColor,
                textFieldBackgroundColor: theme.textFieldBackgroundColor,
                closeIconColor: theme.closeIconColor,
                textFieldConfig: TextFieldConfiguration(
                  onMessageTyping: (status) {
                    /// Do with status
                    debugPrint(status.toString());
                  },
                  compositionThresholdTime: const Duration(seconds: 1),
                  textStyle: TextStyle(color: theme.textFieldTextColor),
                ),
                micIconColor: theme.replyMicIconColor,
                voiceRecordingConfiguration: VoiceRecordingConfiguration(
                  backgroundColor: theme.waveformBackgroundColor,
                  recorderIconColor: theme.recordIconColor,
                  waveStyle: WaveStyle(
                    showMiddleLine: false,
                    waveColor: theme.waveColor ?? Colors.white,
                    extendWaveform: true,
                  ),
                ),
              ),
              chatBubbleConfig: ChatBubbleConfiguration(
                outgoingChatBubbleConfig: ChatBubble(
                  // linkPreviewConfig: LinkPreviewConfiguration(
                  //   backgroundColor: theme.linkPreviewOutgoingChatColor,
                  //   bodyStyle: theme.outgoingChatLinkBodyStyle,
                  //   titleStyle: theme.outgoingChatLinkTitleStyle,
                  // ),
                  receiptsWidgetConfig:
                      const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
                  color: theme.outgoingChatBubbleColor,
                ),
                inComingChatBubbleConfig: ChatBubble(
                  // linkPreviewConfig: LinkPreviewConfiguration(
                  //   linkStyle: TextStyle(
                  //     color: theme.inComingChatBubbleTextColor,
                  //     decoration: TextDecoration.underline,
                  //   ),
                  //   backgroundColor: theme.linkPreviewIncomingChatColor,
                  //   bodyStyle: theme.incomingChatLinkBodyStyle,
                  //   titleStyle: theme.incomingChatLinkTitleStyle,
                  // ),
                  textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  onMessageRead: (message) {
                    /// send your message reciepts to the other client
                    debugPrint('Message Read');
                  },
                  senderNameTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  color: theme.inComingChatBubbleColor,
                ),
              ),
              replyPopupConfig: ReplyPopupConfiguration(
                backgroundColor: theme.replyPopupColor,
                buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
                topBorderColor: theme.replyPopupTopBorderColor,
              ),
              reactionPopupConfig: ReactionPopupConfiguration(
                shadow: BoxShadow(
                  color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
                  blurRadius: 20,
                ),
                backgroundColor: theme.reactionPopupColor,
              ),
              messageConfig: MessageConfiguration(
                messageReactionConfig: MessageReactionConfiguration(
                  backgroundColor: theme.messageReactionBackGroundColor,
                  borderColor: theme.messageReactionBackGroundColor,
                  reactedUserCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                    backgroundColor: theme.backgroundColor,
                    reactedUserTextStyle: TextStyle(
                      color: theme.inComingChatBubbleTextColor,
                    ),
                    reactionWidgetDecoration: BoxDecoration(
                      color: theme.inComingChatBubbleColor,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                          offset: const Offset(0, 20),
                          blurRadius: 40,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                imageMessageConfig: ImageMessageConfiguration(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shareIconConfig: ShareIconConfiguration(
                    defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                    defaultIconColor: theme.shareIconColor,
                  ),
                  onTap: (url) {
                    print(url);
                    print('ああ');
                  },
                ),
                customMessageBuilder: (p0) {
                  return ChatCard2(
                    currentUser: _currentChatUser,
                    showReaction: showReaction,
                    chatController: _chatController,
                    message: p0,
                    messageReactionConfig: MessageReactionConfiguration(
                      backgroundColor: theme.messageReactionBackGroundColor,
                      borderColor: theme.messageReactionBackGroundColor,
                      reactedUserCountTextStyle:
                          TextStyle(color: theme.inComingChatBubbleTextColor),
                      reactionCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                      reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                        backgroundColor: theme.backgroundColor,
                        reactedUserTextStyle: TextStyle(
                          color: theme.inComingChatBubbleTextColor,
                        ),
                        reactionWidgetDecoration: BoxDecoration(
                          color: theme.inComingChatBubbleColor,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                              offset: const Offset(0, 20),
                              blurRadius: 40,
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
              swipeToReplyConfig: SwipeToReplyConfiguration(
                replyIconColor: theme.swipeToReplyIconColor,
              ),
            );
          },
        ));
  }

  Future<void> _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    print(messageType);

    // final id = int.parse(Data.messageList.last.id) + 1;

    final msg = Message(
      // id: id.toString(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: _currentChatUser.id,
      replyMessage: replyMessage,
      // messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
      messageType: messageType, //TODO カスタム
      chatRoomId: widget.chatRoomId,
    );

    _chatController.addMessage(msg);

    // await ref.read(chatControllerProvider(widget.chatRoomId).notifier).createMessage(msg);
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered;
    // });
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    // });
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
