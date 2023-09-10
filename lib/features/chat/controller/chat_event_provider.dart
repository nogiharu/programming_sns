// import 'package:programming_sns/constants/appwrite_constants.dart';
// import 'package:programming_sns/core/appwrite_providers.dart';
// import 'package:programming_sns/core/dependencies.dart';
// import 'package:programming_sns/extensions/message_ex.dart';
// import 'package:programming_sns/models/user_model.dart';

// final chatEventProvider = Provider((ref) {
//   final stream = ref.watch(appwriteRealtimeProvider).subscribe([
//     AppwriteConstants.messagesDocmentsChannels,
//     AppwriteConstants.usersDocumentsChannels,
//   ]).stream;

//   stream.listen((event) {
//     if (event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create')) {
//       print('USER_CREATE');
//       print(event.payload);
//       final user = UserModel.fromMap(event.payload);
//       addUser(UserModel.toChatUser(user));
//     }
//     if (event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create')) {
//       print('MESSAGE_CREATE');
//       print(event.payload);
//       final message = MessageEX.fromMap(event.payload);
//       addMessage(message);
//     }
//     if (event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update')) {
//       print('USER_UPDATE');
//       print(event.payload);
//       // final user = UserModel.fromMap(event.payload);
//       // addUser(UserModel.toChatUser(user));
//     }
//   });
// });
