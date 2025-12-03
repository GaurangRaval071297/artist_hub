import 'package:flutter/material.dart';

class AppColors {
  // Single colors
  static const Color primaryColor = Color(0xFF0066FF);
  static const Color primary = Color(0xFF0066FF); // Added this for consistency
  static const Color secondary = Color(0xFFFF9800);

  // White and Grey shades
  static const Color white = Colors.white;
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);

  // Black
  static const Color black = Colors.black;
  static const Color black87 = Color(0xDD000000);

  // Gradient
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF673AB7), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Additional gradients you might need
  static const LinearGradient registerBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0066FF), // primary with opacity variations
      Color(0xFF0066FF),
      Colors.white,
      Colors.white,
    ],
    stops: [0, 0.3, 0.3, 1],
  );

  static const LinearGradient purplePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF673AB7), Color(0xFFE91E63)],
  );
}