import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/core/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    if (supabase.auth.currentUser == null) {
      await supabase.auth.signInAnonymously().catchError(
            ((e) => errorMessage(error: e)),
          );
    }
    return supabase.auth.currentUser!;
  }
}
