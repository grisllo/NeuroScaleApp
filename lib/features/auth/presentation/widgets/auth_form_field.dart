import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.validator,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final String label;
  final String? hint;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final VoidCallback? onFieldSubmitted;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      onFieldSubmitted: onFieldSubmitted != null
          ? (_) => onFieldSubmitted!()
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
