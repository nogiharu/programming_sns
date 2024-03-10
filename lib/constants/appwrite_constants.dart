class AppwriteConstants {
  static const String kProjectId = '652a84b1428731a3fe13';
  static const String kDatabaseId = '652a857964373452cc09';
  // static const String endPoint = 'http://192.168.1.3:80/v1';
  static const String kEndPoint = 'http://localhost/v1';
  static const String kMessagesCollection = '652a860839fe40651dba';
  static const String kUsersCollection = '652bbad062129307289e';
  static const String kChatRoomCollection = '652db5fe9905218ab7f6';
  static const String kNotificationCollection = '65e8c9079ca0b6fcea90';

  static const String kMessageImagesBucket = '65ada7b0d8ff019e2d32';

  static String imageUrl(String imageId) =>
      '$kEndPoint/storage/buckets/$kMessageImagesBucket/files/$imageId/view?project=$kProjectId&mode=admin';

  static const kMessagesDocmentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kMessagesCollection}.documents';

  static const kUsersDocumentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kUsersCollection}.documents';

  static const kChatRoomDocmentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kChatRoomCollection}.documents';
}

// Androidの場合
// harasakiyuuya@MacBookPro2023 twitter_clone % adb root
// restarting adbd as root
// harasakiyuuya@MacBookPro2023 twitter_clone % adb reverse tcp:80 tcp:80

// 追加
// android {
//   defaultConfig {
//     minSdkVersion 19
//     multiDexEnabled true // multidexサポートライブラリを使用する
//   }
// }
