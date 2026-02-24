/// Duration constants for animations and timing
/// 
/// All duration values used in the application should be defined here.
library;

class Durations {
  // Short durations
  static const Duration short = Duration(milliseconds: 150);
  static const Duration shortMedium = Duration(milliseconds: 200);
  
  // Medium durations
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration mediumLong = Duration(milliseconds: 400);
  
  // Long durations
  static const Duration long = Duration(milliseconds: 500);
  static const Duration extraLong = Duration(milliseconds: 700);
  
  // Specific use cases
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogTransition = Duration(milliseconds: 200);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Private constructor to prevent instantiation
  Durations._();
}

