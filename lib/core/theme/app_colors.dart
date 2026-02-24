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
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successStatus = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warningStatus = Color(0xFFFF9800);
  static const Color infoStatus = Color(0xFF2196F3);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Divider Colors
  static const Color divider = Color(0xFFE0E0E0);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  
  // Private constructor to prevent instantiation
  AppColors._();
}

