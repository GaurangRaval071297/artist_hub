import 'package:flutter/material.dart';

class AppColors {
  // Single colors
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFFFF9800);

  // Gradient
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF673AB7), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
