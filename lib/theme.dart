import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFF3FFCA);
  static const Color primaryContainer = Color(0xFFCAFD00);
  static const Color primaryDim = Color(0xFFBEEE00);
  static const Color onPrimary = Color(0xFF516700);
  static const Color onPrimaryFixed = Color(0xFF3A4A00);
  static const Color onPrimaryFixedVariant = Color(0xFF526900);

  static const Color secondary = Color(0xFF00E3FD);
  static const Color secondaryContainer = Color(0xFF006875);
  static const Color onSecondary = Color(0xFF004D57);
  static const Color secondaryDim = Color(0xFF00D4EC);

  static const Color tertiary = Color(0xFFA68CFF);
  static const Color tertiaryContainer = Color(0xFF7C4DFF);
  static const Color onTertiary = Color(0xFF25006B);

  static const Color error = Color(0xFFFF7351);
  static const Color errorContainer = Color(0xFFB92902);
  static const Color onError = Color(0xFF450900);

  // Surface Colors
  static const Color background = Color(0xFF0D0E13);
  static const Color surface = Color(0xFF0D0E13);
  static const Color surfaceVariant = Color(0xFF24252D);
  static const Color surfaceBright = Color(0xFF2A2C34);
  static const Color surfaceDim = Color(0xFF0D0E13);
  
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF121319);
  static const Color surfaceContainer = Color(0xFF181920);
  static const Color surfaceContainerHigh = Color(0xFF1E1F26);
  static const Color surfaceContainerHighest = Color(0xFF24252D);

  static const Color onSurface = Color(0xFFF7F5FD);
  static const Color onSurfaceVariant = Color(0xFFABAAB1);
  static const Color outline = Color(0xFF75757B);
  static const Color outlineVariant = Color(0xFF47474E);

  // Kinetic Gradient
  static const LinearGradient kineticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
    stops: [0.0, 1.0],
    transform: GradientRotation(135 * 3.14159 / 180),
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Color(0xFF4A5E00),
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: Color(0xFFE8FBFF),
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onError: AppColors.onError,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),

      // Components
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimaryFixed,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
