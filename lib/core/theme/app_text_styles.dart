/// Application text styles
/// 
/// All text styles used in the application should be defined here.
/// Use these styles instead of creating TextStyle objects directly in widgets.
library;

import 'package:flutter/material.dart';
import '../constants/font_sizes.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge = TextStyle(
    fontSize: FontSizes.displayLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );
  
  static TextStyle displayMedium = TextStyle(
    fontSize: FontSizes.displayMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  static TextStyle displaySmall = TextStyle(
    fontSize: FontSizes.displaySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  // Headline Styles (sleek: slightly tighter)
  static TextStyle headlineLarge = TextStyle(
    fontSize: FontSizes.headlineLarge,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );
  
  static TextStyle headlineMedium = TextStyle(
    fontSize: FontSizes.headlineMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  static TextStyle headlineSmall = TextStyle(
    fontSize: FontSizes.headlineSmall,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  // Title Styles
  static TextStyle titleLarge = TextStyle(
    fontSize: FontSizes.titleLarge,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  static TextStyle titleMedium = TextStyle(
    fontSize: FontSizes.titleMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  static TextStyle titleSmall = TextStyle(
    fontSize: FontSizes.titleSmall,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  // Body Styles
  static TextStyle bodyLarge = TextStyle(
    fontSize: FontSizes.bodyLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyMedium = TextStyle(
    fontSize: FontSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
  );
  
  static TextStyle bodySmall = TextStyle(
    fontSize: FontSizes.bodySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );
  
  // Label Styles
  static TextStyle labelLarge = TextStyle(
    fontSize: FontSizes.labelLarge,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = TextStyle(
    fontSize: FontSizes.labelMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall = TextStyle(
    fontSize: FontSizes.labelSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
  
  // Button Styles
  static TextStyle buttonLarge = TextStyle(
    fontSize: FontSizes.buttonLarge,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );
  
  static TextStyle buttonMedium = TextStyle(
    fontSize: FontSizes.buttonMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );
  
  static TextStyle buttonSmall = TextStyle(
    fontSize: FontSizes.buttonSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );
  
  // Private constructor to prevent instantiation
  AppTextStyles._();
}

