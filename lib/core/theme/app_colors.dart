/// Application color palette
/// 
/// All colors used in the application should be defined here.
/// Use these colors instead of hardcoded Color values.
library;

import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (from design system)
  static const Color primary = Color(0xFFFACC15); // Primary - #FACC15
  static const Color primaryDark = Color(0xFFF0B100);
  static const Color primaryLight = Color(0xFFFFF3C4);
  
  static const Color secondary = Color(0xFF101828); // Secondary - #101828
  static const Color secondaryDark = Color(0xFF0B1220);
  static const Color secondaryLight = Color(0xFF1D2939);
  
  // Status Colors
  static const Color success = Color(0xFF00C950); // Success - #00C950
  static const Color pending = Color(0xFFF0B100); // Pending - #F0B100
  static const Color danger = Color(0xFFFB2C36); // Danger - #FB2C36
  static const Color warning = pending;
  static const Color info = primary;
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successStatus = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warningStatus = Color(0xFFFF9800);
  static const Color infoStatus = Color(0xFF2196F3);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF424242);
  
  // Divider Colors
  static const Color divider = Color(0xFFE2E8F0);
  
  // Shadow Colors (softer for sleek look)
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMedium = Color(0x15000000);
  static const Color shadowStrong = Color(0x1A000000);

  // Map screen (dark Google Maps–style UI)
  static const Color mapBarBackground = Color(0xFF2D2D2D);
  static const Color mapTeal = Color(0xFF00BFA5);
  static const Color mapChipBackground = Color(0xFF3D3D3D);
  static const Color mapNavBackground = Color(0xFF1F1F1F);
  static const Color mapSearchBackground = Color(0xFF383838);
  static const Color mapSheetBackground = Color(0xFF2D2D2D);
  static const Color mapTextOnDark = Color(0xFFFFFFFF);
  static const Color mapTextMuted = Color(0xFFB0B0B0);

  // Private constructor to prevent instantiation
  AppColors._();
}

