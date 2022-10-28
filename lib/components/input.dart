import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatelessWidget {
  const Input(
      {Key? key,
      this.maxLines = 1,
      this.inputFormatters,
      this.validator,
      required this.controller,
      required this.hint,
      this.onSaved,
      this.obscure = false,
      this.autofocus = false,
      this.type = TextInputType.text,
      
      })
      : super(key: key);

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final inputFormatters;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final Function(String?)? onSaved;
  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters = this.inputFormatters != null ? this.inputFormatters : [];

    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      obscureText: obscure,
      keyboardType: type,
      maxLines: obscure ? 1 : maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      onSaved: onSaved,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
    );
  }
}
