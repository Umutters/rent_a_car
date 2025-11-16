import 'package:flutter/material.dart';

/// Centralized app color palette
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary brand colors
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color accent = Color(0xFF1976D2); // Blue

  // Gradient colors
  static const Color gradientStart = Colors.white;
  static const Color gradientEnd = Color(0xFF1976D2);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textDark = Colors.black;
  static const Color textGrey = Color(0xFF9E9E9E);

  // Background colors
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundDark = Color(0xFF2C2C2C);
  static const Color backgroundLight = Color(0xFFE0E0E0);

  // Card colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Colors.black12;

  // Icon colors
  static const Color iconLight = Colors.white;
  static const Color iconDark = Colors.black;
  static const Color iconGrey = Color(0xFF757575);

  // Transparent overlays
  static const Color overlay = Colors.white24;
  static const Color overlayLight = Colors.white12;

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const RadialGradient primaryRadialGradient = RadialGradient(
    colors: [gradientStart, gradientEnd],
    center: Alignment.topRight,
    radius: 1.0,
    stops: [0.0, 1.0],
  );
}
