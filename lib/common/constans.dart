import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase にアクセスするためのクライアントインスタンス
final supabase = Supabase.instance.client;

const defaultError = '''
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ''';
