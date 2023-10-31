import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';

final snackBarProvider = Provider.family((ref, String msg) {
  final messengerState = ref.read(scaffoldMessengerKeyProvider).currentState;
  messengerState?.showSnackBar(SnackBar(content: Text(msg)));
});


// void wrapperShowSnackBar(BuildContext context, String content) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(content)),
//   );
// }
