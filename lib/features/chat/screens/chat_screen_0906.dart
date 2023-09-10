// import 'package:any_link_preview/any_link_preview.dart';
// import 'package:appwrite/appwrite.dart';
// import 'package:chatview/chatview.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:programming_sns/constants/appwrite_constants.dart';
// import 'package:programming_sns/extensions/message_ex.dart';
// import 'package:programming_sns/extensions/widget_ref_ex.dart';
// import 'package:programming_sns/features/chat/controller/chat_controller.dart';
// import 'package:programming_sns/features/chat/controller/test.dart';
// import 'package:programming_sns/features/chat/widgets/chat_card.dart';
// import 'package:programming_sns/features/user/providers/user_model_provider.dart';
// import 'package:programming_sns/models/user_model.dart';
// import 'package:programming_sns/temp/data2.dart';
// import 'package:programming_sns/temp/theme.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//   static const Map<String, dynamic> metaData = {
//     'path': '/chat',
//     'label': 'チャット',
//     'icon': Icon(Icons.chat),
//     'index': 3,
//   };

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   ChatControllerNotifier get chatControllerNotifier => ref.read(chatControllerProvider.notifier);
//   ChatController get chatController => ref.read(chatControllerProvider.notifier).chatController;

//   AppTheme theme = LightTheme();
//   bool isDarkTheme = false;

//   bool showReaction = true;

//   @override
//   void initState() {
//     super.initState();
//     chatControllerNotifier.initScrollController();
//     // chatController.scrollController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ref.watch(appwriteRealtimeMessageProvider);

//     initializeDateFormatting("ja");

//     return Scaffold(

//         /// USER
//         body: ref.watchEX(
//       userModelProvider,
//       complete: (currentUserModel) {
//         final ChatUser currentChatUser = UserModel.toChatUser(currentUserModel);

//         /// CHAT
//         return ref.watchEX(
//           chatControllerProvider,
//           complete: (chatController) {
//             /// REALTIME
//             return ref.watch(appwriteRealtimeMessageProvider).when(
//               data: (data) {
//                 const messagesDocments =
//                     'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollection}.documents';
//                 if (data.events.contains('$messagesDocments.*.create')) {
//                   final message = MessageEX.fromMap(data.payload);
//                   chatController.addMessage(message);
//                   // ref.read(chatControllerProvider.notifier).realtimeMessageUpdate(message);
//                 }
//                 return ChatView(
//                   currentUser: currentChatUser,
//                   chatController: chatController,
//                   onSendTap: chatControllerNotifier.onSendMessage,
//                   featureActiveConfig: const FeatureActiveConfig(
//                     enableSwipeToReply: !kIsWeb, // TODO
//                     enableSwipeToSeeTime: false,
//                   ),
//                   chatViewState: ChatViewState.hasMessages,
//                   appBar: AppBar(
//                     title: const Text('AppBar'),
//                   ),

//                   /// TODO chat全体背景
//                   chatBackgroundConfig: ChatBackgroundConfiguration(
//                     messageTimeIconColor: theme.messageTimeIconColor,
//                     messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
//                     defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
//                       textStyle: TextStyle(
//                         color: theme.chatHeaderColor,
//                         fontSize: 17,
//                       ),
//                     ),
//                     backgroundColor: Colors.amber.shade100,
//                   ),
//                   sendMessageConfig: SendMessageConfiguration(
//                     allowRecordingVoice: false, // ボイスなし
//                     imagePickerIconsConfig: const ImagePickerIconsConfiguration(
//                       cameraImagePickerIcon: SizedBox(), // カメラなし
//                     ),
//                     replyMessageColor: theme.replyMessageColor,
//                     defaultSendButtonColor: Colors.amber,
//                     replyDialogColor: Colors.amber.shade200, // リプライ背景色
//                     replyTitleColor: Colors.amber.shade900,

//                     textFieldBackgroundColor: Colors.grey.shade100, // 背景色
//                     closeIconColor: theme.closeIconColor,
//                     textFieldConfig: TextFieldConfiguration(
//                       maxLines: 100, // 入力文字の行
//                       contentPadding: const EdgeInsets.all(10),
//                       hintText: '文字入れてね', // TODO ヒント
//                       compositionThresholdTime: const Duration(seconds: 5),
//                       textStyle: TextStyle(
//                         color: theme.textFieldTextColor,
//                       ),
//                     ),
//                   ),
//                   // TODO わからん
//                   chatBubbleConfig: ChatBubbleConfiguration(
//                     onDoubleTap: (message) {
//                       setState(() {
//                         showReaction = !showReaction;
//                       });
//                     },
//                     // TODO わからん
//                     outgoingChatBubbleConfig: const ChatBubble(
//                       receiptsWidgetConfig: ReceiptsWidgetConfig(
//                         showReceiptsIn: ShowReceiptsIn.all, // チャット横幅
//                       ),
//                     ),
//                   ),

//                   messageConfig: MessageConfiguration(
//                     customMessageBuilder: (p0) {
//                       return ChatCard(
//                         currentUser: currentChatUser,
//                         showReaction: showReaction,
//                         chatController: chatController,
//                         message: p0,
//                       );
//                     },
//                   ),
//                   profileCircleConfig: const ProfileCircleConfiguration(
//                     profileImageUrl: Data.profileImage,
//                   ),

//                   repliedMessageConfig: RepliedMessageConfiguration(
//                     backgroundColor: Colors.amber,
//                     verticalBarColor: Colors.amber,
//                     repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
//                       enableHighlightRepliedMsg: true,
//                       highlightColor: Colors.amber.shade100,
//                       highlightScale: 1.1,
//                     ),
//                     textStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.25,
//                     ),
//                     replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
//                   ),

//                   /// TODO スワイプ
//                   swipeToReplyConfig: SwipeToReplyConfiguration(
//                     replyIconColor: theme.swipeToReplyIconColor,
//                   ),
//                 );
//               },
//               error: (error, stackTrace) {
//                 return const Text('text');
//               },
//               loading: () {
//                 return ChatView(
//                   currentUser: currentChatUser,
//                   chatController: chatController,
//                   onSendTap: chatControllerNotifier.onSendMessage,
//                   featureActiveConfig: const FeatureActiveConfig(
//                     enableSwipeToReply: !kIsWeb, // TODO
//                     enableSwipeToSeeTime: false,
//                   ),
//                   chatViewState: ChatViewState.hasMessages,
//                   appBar: AppBar(
//                     title: const Text('AppBar'),
//                   ),

//                   /// TODO chat全体背景
//                   chatBackgroundConfig: ChatBackgroundConfiguration(
//                     messageTimeIconColor: theme.messageTimeIconColor,
//                     messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
//                     defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
//                       textStyle: TextStyle(
//                         color: theme.chatHeaderColor,
//                         fontSize: 17,
//                       ),
//                     ),
//                     backgroundColor: Colors.amber.shade100,
//                   ),
//                   sendMessageConfig: SendMessageConfiguration(
//                     allowRecordingVoice: false, // ボイスなし
//                     imagePickerIconsConfig: const ImagePickerIconsConfiguration(
//                       cameraImagePickerIcon: SizedBox(), // カメラなし
//                     ),
//                     replyMessageColor: theme.replyMessageColor,
//                     defaultSendButtonColor: Colors.amber,
//                     replyDialogColor: Colors.amber.shade200, // リプライ背景色
//                     replyTitleColor: Colors.amber.shade900,

//                     textFieldBackgroundColor: Colors.grey.shade100, // 背景色
//                     closeIconColor: theme.closeIconColor,
//                     textFieldConfig: TextFieldConfiguration(
//                       maxLines: 100, // 入力文字の行
//                       contentPadding: const EdgeInsets.all(10),
//                       hintText: '文字入れてね', // TODO ヒント
//                       compositionThresholdTime: const Duration(seconds: 5),
//                       textStyle: TextStyle(
//                         color: theme.textFieldTextColor,
//                       ),
//                     ),
//                   ),
//                   // TODO わからん
//                   chatBubbleConfig: ChatBubbleConfiguration(
//                     onDoubleTap: (message) {
//                       setState(() {
//                         showReaction = !showReaction;
//                       });
//                     },
//                     // TODO わからん
//                     outgoingChatBubbleConfig: const ChatBubble(
//                       receiptsWidgetConfig: ReceiptsWidgetConfig(
//                         showReceiptsIn: ShowReceiptsIn.all, // チャット横幅
//                       ),
//                     ),
//                   ),

//                   messageConfig: MessageConfiguration(
//                     customMessageBuilder: (p0) {
//                       return ChatCard(
//                         currentUser: currentChatUser,
//                         showReaction: showReaction,
//                         chatController: chatController,
//                         message: p0,
//                       );
//                     },
//                   ),
//                   profileCircleConfig: const ProfileCircleConfiguration(
//                     profileImageUrl: Data.profileImage,
//                   ),

//                   repliedMessageConfig: RepliedMessageConfiguration(
//                     backgroundColor: Colors.amber,
//                     verticalBarColor: Colors.amber,
//                     repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
//                       enableHighlightRepliedMsg: true,
//                       highlightColor: Colors.amber.shade100,
//                       highlightScale: 1.1,
//                     ),
//                     textStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.25,
//                     ),
//                     replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
//                   ),

//                   /// TODO スワイプ
//                   swipeToReplyConfig: SwipeToReplyConfiguration(
//                     replyIconColor: theme.swipeToReplyIconColor,
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     ));
//   }
// }
