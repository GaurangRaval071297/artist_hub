import 'package:flutter/material.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showMessage(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  static void _showToast(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: backgroundColor,
        content: Text(message, style: TextStyle(color: textColor)),
      ),
    );
  }
}
