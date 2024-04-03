import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static final String kProjectId = dotenv.env['kProjectId'] ?? '';
  static final String kDatabaseId = dotenv.env['kDatabaseId'] ?? '';
  static final String kApiKey = dotenv.env['kApiKey'] ?? '';
  static final String kEndPoint = dotenv.env['kEndPoint'] ?? '';
  static final String kMessagesCollection = dotenv.env['kMessagesCollection'] ?? '';
  static final String kUsersCollection = dotenv.env['kUsersCollection'] ?? '';
  static final String kChatRoomCollection = dotenv.env['kChatRoomCollection'] ?? '';
  static final String kNotificationCollection = dotenv.env['kNotificationCollection'] ?? '';
  static final String kMessageImagesBucket = dotenv.env['kMessageImagesBucket'] ?? '';

  static String imageUrl(String imageId) =>
      '$kEndPoint/storage/buckets/$kMessageImagesBucket/files/$imageId/view?project=$kProjectId&mode=admin';

  static final kMessagesDocmentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kMessagesCollection}.documents';

  static final kUsersDocumentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kUsersCollection}.documents';

  static final kChatRoomDocmentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kChatRoomCollection}.documents';

  static final kNotificationDocmentsChannels =
      'databases.${AppwriteConstants.kDatabaseId}.collections.${AppwriteConstants.kNotificationCollection}.documents';
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
