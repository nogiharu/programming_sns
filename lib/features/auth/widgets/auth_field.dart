import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool isObscureText = false;

  @override
  Widget build(BuildContext context) {
    bool isPassword = widget.labelText.contains('パスワー');

    return TextFormField(
      // validator: validator,
      controller: widget.controller,
      obscureText: isPassword && isObscureText,
      decoration: InputDecoration(
        // アイコン
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isObscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => isObscureText = !isObscureText),
              )
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: Text(
          widget.labelText,
          style: const TextStyle(fontSize: 20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.amber,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.all(22),
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
      ),
    );
  }
}
