class AppwriteConstants {
  static const String projectId = '64dc5f8696d50a9ca2ca';
  static const String databaseId = '64e2914ec29631d7f0f7';
  static const String endPoint = 'http://192.168.1.3:80/v1';
  // static const String endPoint = 'http://localhost/v1';
  static const String messagesCollection = '64e2917e86d88d32700f';
  static const String usersCollection = '64e9c32e0b2309c2e450';
  // static const String tweetsCollection = '64aa43cfe8683324cc8a';
  // static const String imagesBucket = '64ac7e5c87212f830a5e';
  // static const String notificationsCollection = '64c4d7d817d658b7e996';

  // static String imageUrl(String imageId) =>
  //     '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';

  static const messagesDocmentsChannels =
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollection}.documents';

  static const usersDocumentsChannels =
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents';
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
