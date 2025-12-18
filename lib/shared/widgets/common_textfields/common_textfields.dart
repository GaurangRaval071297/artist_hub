import 'package:flutter/material.dart';

class CommonTextfields extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool? obsureText;
  final String? Function(String?)? validator;
  final Function? onTap;
  final bool? readOnly;
  final Widget? preFixIcon;
  final Widget? sufFixIcon;
  final TextInputAction? inputAction; // Change this to textInputAction
  final int? maxLines;
  final int? minLines;

  const CommonTextfields({
    super.key,
    required this.keyboardType,
    required this.controller,
    required this.hintText,
    this.maxLength,
    this.obsureText,
    this.validator,
    this.readOnly,
    this.preFixIcon,
    this.sufFixIcon,
    this.onTap,
    this.inputAction, // Change this to textInputAction
    this.maxLines,
    this.minLines
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: inputAction, // This should match the parameter name
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obsureText ?? false,
      validator: validator,
      readOnly: readOnly ?? false,
      onTap: () {
        if ((readOnly ?? false) && onTap != null) {
          onTap!();
        }
      },
      decoration: InputDecoration(
        prefixIcon: preFixIcon,
        suffixIcon: sufFixIcon,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,

        errorStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}