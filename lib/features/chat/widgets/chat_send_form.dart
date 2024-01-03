import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/features/theme/theme_color.dart';

class ChatSendForm extends ConsumerStatefulWidget {
  const ChatSendForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatSendFormState();
}

class _ChatSendFormState extends ConsumerState<ChatSendForm> {
  final TextEditingController textEditingController = TextEditingController();

  bool isTextSend = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: TextInputType.none,
        onChanged: (value) {
          setState(() {
            isTextSend = value.isNotEmpty;
          });
          print(value);
        },
        maxLines: MediaQuery.of(context).size.height ~/ 30,
        minLines: 1,
        controller: textEditingController,
        cursorColor: Colors.amber,
        decoration: InputDecoration(
          hintText: '文字入れてね！',
          suffixIcon: IconButton(
              onPressed: () {
                // if (cont.text.isNotEmpty) {
                //   _handleSendPressed(types.PartialText(text: cont.text));
                //   cont.clear();
                // }
              },
              icon: Icon(
                isTextSend ? Icons.send : Icons.photo,
                color: ThemeColor.main,
              )),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: ThemeColor.main,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
      ),
    );
  }
}
