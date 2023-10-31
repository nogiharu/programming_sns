class AppwriteConstants {
  static const String projectId = '652a84b1428731a3fe13';
  static const String databaseId = '652a857964373452cc09';
  static const String endPoint = 'http://192.168.1.3:80/v1';
  // static const String endPoint = 'http://localhost/v1';
  static const String messagesCollection = '652a860839fe40651dba';
  static const String usersCollection = '652bbad062129307289e';
  static const String chatRoomCollection = '652db5fe9905218ab7f6';

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
