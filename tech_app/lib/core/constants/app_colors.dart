import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF1565C0);       // Deep Blue
  static const Color accent = Color(0xFF1E88E5);         // Medium Blue
  static const Color gold = Color(0xFFF57C00);           // Warm Orange/Gold

  // Background
  static const Color background = Color(0xFFF7F9FC);    // Light gray-blue
  static const Color surface = Color(0xFFFFFFFF);        // Pure white
  static const Color surfaceVariant = Color(0xFFEFF4FB); // Soft blue-tinted gray

  // Text
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6478);
  static const Color textHint = Color(0xFF9BA5B5);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1E88E5);

  // Borders & Dividers
  static const Color border = Color(0xFFDDE4EF);
  static const Color divider = Color(0xFFEAEFF7);

  // Overlay
  static const Color overlay = Color(0x40000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFEFF4FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
