import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class ShadcnThemeConfig {
  // Modern Earth Tone Color Palette
  static const Color primaryColor = Color(0xFF2D6A4F); // Forest Green
  static const Color secondaryColor = Color(0xFF52B788); // Sage Green
  static const Color accentColor = Color(0xFFD4A574); // Warm Sand
  static const Color errorColor = Color(0xFFD64545); // Terracotta Red
  static const Color successColor = Color(0xFF40916C); // Deep Green
  static const Color warningColor = Color(0xFFE9C46A); // Golden Yellow

  static const Color backgroundColor = Color(0xFFF8F9FA); // Soft White
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color textPrimaryColor = Color(0xFF1B263B); // Deep Blue-Gray
  static const Color textSecondaryColor = Color(0xFF6C757D); // Medium Gray
  static const Color textMutedColor = Color(0xFF9CA3AF); // Light Gray

  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFF3F4F6);

  // Create custom ShadcnUI theme
  static ShadThemeData createLightTheme() {
    final colorScheme = ShadColorScheme(
      background: backgroundColor,
      foreground: textPrimaryColor,
      card: cardColor,
      cardForeground: textPrimaryColor,
      popover: surfaceColor,
      popoverForeground: textPrimaryColor,
      primary: primaryColor,
      primaryForeground: Colors.white,
      secondary: secondaryColor,
      secondaryForeground: Colors.white,
      muted: dividerColor,
      mutedForeground: textMutedColor,
      accent: accentColor,
      accentForeground: textPrimaryColor,
      destructive: errorColor,
      destructiveForeground: Colors.white,
      border: borderColor,
      input: borderColor,
      ring: primaryColor,
      selection: primaryColor.withOpacity(0.2),
    );

    return ShadThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      // Custom text theme using Poppins
      textTheme: ShadTextTheme(
        family: GoogleFonts.poppins().fontFamily!,
        h1Large: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        h1: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        h2: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        h3: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        h4: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        p: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        blockquote: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        table: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
        ),
        list: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        lead: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: 1.6,
        ),
        large: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        small: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        muted: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMutedColor,
          height: 1.4,
        ),
      ),
      // Border
      radius: BorderRadius.circular(12),
      // Disable animations for better performance (can be enabled later)
      disableSecondaryBorder: false,
    );
  }

  // Create dark theme variant (optional)
  static ShadThemeData createDarkTheme() {
    final colorScheme = ShadColorScheme(
      background: const Color(0xFF0F172A), // Dark Blue-Gray
      foreground: const Color(0xFFF8FAFC), // Off White
      card: const Color(0xFF1E293B),
      cardForeground: const Color(0xFFF8FAFC),
      popover: const Color(0xFF1E293B),
      popoverForeground: const Color(0xFFF8FAFC),
      primary: secondaryColor,
      primaryForeground: const Color(0xFF0F172A),
      secondary: const Color(0xFF334155),
      secondaryForeground: const Color(0xFFF8FAFC),
      muted: const Color(0xFF1E293B),
      mutedForeground: const Color(0xFF94A3B8),
      accent: accentColor,
      accentForeground: const Color(0xFF0F172A),
      destructive: errorColor,
      destructiveForeground: Colors.white,
      border: const Color(0xFF334155),
      input: const Color(0xFF334155),
      ring: secondaryColor,
      selection: secondaryColor.withOpacity(0.2),
    );

    return ShadThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      textTheme: ShadTextTheme(
        family: GoogleFonts.poppins().fontFamily!,
        h1Large: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        h1: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        h2: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        h3: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        h4: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        p: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
      ),
      radius: BorderRadius.circular(12),
      disableSecondaryBorder: false,
    );
  }
}
