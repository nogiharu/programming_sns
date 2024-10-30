import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputField extends StatefulWidget {
  /// コントローラー
  final TextEditingController controller;

  /// プレースホルダー
  String? hintText;

  /// ラベル
  String? labelText;

  /// リードオンリー
  bool isReadOnly;

  /// ボーダーカラーを黒くする
  bool isBorderBlack;

  /// バリデーション
  final String? Function(String?)? validator;

  /// 複数行の入力を許可
  bool isMaxLines;

  /// パディング
  double contentPadding;

  /// マックスレングス
  int? maxLength;

  InputField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.isReadOnly = false,
    this.isBorderBlack = true,
    this.validator,
    this.isMaxLines = false,
    this.contentPadding = 15,
    this.maxLength,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool isObscureText = false;

  @override
  Widget build(BuildContext context) {
    bool isPassword = widget.labelText?.contains('パスワード') ?? false;

    return TextFormField(
      maxLength: widget.maxLength,
      readOnly: widget.isReadOnly,
      validator: widget.validator,
      controller: widget.controller,
      maxLines: widget.isMaxLines ? null : 1, // 複数行の入力を許可
      keyboardType: widget.isMaxLines ? TextInputType.multiline : null, // 複数行の入力を許可
      obscureText: isPassword && isObscureText,
      decoration: InputDecoration(
        counterText: '', // カウンターを非表示にする
        // padding除去
        isDense: true,
        // アイコン
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isObscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => isObscureText = !isObscureText),
              )
            : null,
        floatingLabelBehavior: widget.labelText != null ? FloatingLabelBehavior.always : null,
        // ラベル
        label: widget.labelText != null
            ? Text(
                widget.labelText!,
                style: const TextStyle(fontSize: 15),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.amber,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: widget.isBorderBlack ? Colors.black : Colors.grey.shade300,
          ),
        ),
        contentPadding: EdgeInsets.all(widget.contentPadding),
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
      ),
    );
  }
}
