import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase にアクセスするためのクライアントインスタンス
final supabase = Supabase.instance.client;


// final authStateProvider = StreamProvider<AuthState?>((ref) {
//   return supabase.auth.onAuthStateChange;
// });
