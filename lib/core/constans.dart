import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase にアクセスするためのクライアントインスタンス
final supabase = Supabase.instance.client;

const defaultError = '''
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ''';

// final minio = Minio(
//   endPoint: 'play.min.io',
//   accessKey: 'Q3AM3UQ867SPQQA43P2F',
//   secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
// );
