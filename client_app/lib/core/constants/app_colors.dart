import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF1A237E);       // Deep Navy
  static const Color accent = Color(0xFF2979FF);         // Electric Blue
  static const Color gold = Color(0xFFFFB300);           // Amber Gold

  // Background
  static const Color background = Color(0xFF0D1117);     // Dark base
  static const Color surface = Color(0xFF161B22);        // Card surface
  static const Color surfaceVariant = Color(0xFF1C2333); // Elevated card

  // Text
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textHint = Color(0xFF484F58);

  // Status
  static const Color success = Color(0xFF3FB950);
  static const Color error = Color(0xFFF85149);
  static const Color warning = Color(0xFFD29922);
  static const Color info = Color(0xFF58A6FF);

  // Borders & Dividers
  static const Color border = Color(0xFF30363D);
  static const Color divider = Color(0xFF21262D);

  // Overlay
  static const Color overlay = Color(0x80000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFF176)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF161B22), Color(0xFF1C2333)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
