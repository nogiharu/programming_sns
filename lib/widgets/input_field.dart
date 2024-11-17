import 'package:flutter/material.dart';
import 'package:programming_sns/theme/theme_color.dart';

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

  /// バリデーション
  final String? Function(String?)? validator;

  /// 複数行の入力を許可
  bool isMaxLines;

  /// パディング
  double contentPadding;

  /// マックスレングス
  int? maxLength;

  /// 末尾アイコン
  Widget? suffixIcon;

  /// 入力値を隠す
  bool isObscureText;

  /// ラベルのアニメーション
  bool isLabelAnimation;

  /// ボーダーカラー
  Color? borderColor;

  InputField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.isReadOnly = false,
    this.validator,
    this.isMaxLines = false,
    this.contentPadding = 15,
    this.maxLength,
    this.suffixIcon,
    this.isObscureText = false,
    this.isLabelAnimation = false,
    this.borderColor,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // フォーカスの変更時にUIを更新
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      maxLength: widget.maxLength,
      readOnly: widget.isReadOnly,
      validator: widget.validator,
      controller: widget.controller,
      maxLines: widget.isMaxLines ? null : 1, // 複数行の入力を許可
      keyboardType: widget.isMaxLines ? TextInputType.multiline : null, // 複数行の入力を許可
      obscureText: widget.isObscureText,
      decoration: InputDecoration(
        counterText: '', // カウンターを非表示にする
        // padding除去
        isDense: true,
        // アイコン
        suffixIcon: widget.suffixIcon,

        floatingLabelBehavior: widget.isLabelAnimation ? null : FloatingLabelBehavior.always,
        // ラベル
        label: widget.labelText != null
            ? Text(
                widget.labelText!,
                style: TextStyle(
                  fontSize: 15,
                  color: _focusNode.hasFocus
                      ? ThemeColor.strong
                      : widget.isLabelAnimation
                          ? ThemeColor.strong
                          : null,
                ),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: ThemeColor.main,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.black),
        ),
        contentPadding: EdgeInsets.all(widget.contentPadding),
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
      ),
    );
  }
}
