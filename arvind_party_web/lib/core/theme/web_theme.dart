// arvind_party_web/lib/core/theme/web_theme.dart
import 'package:flutter/material.dart';

class WebTheme {
  static const Color primary    = Color(0xFFFF8906);
  static const Color secondary  = Color(0xFF64B5F6);
  static const Color gold       = Color(0xFFFFC107);
  static const Color bgDark     = Color(0xFF0F0E17);
  static const Color bgCard     = Color(0xFF15141F);
  static const Color bgElevated = Color(0xFF1E1D2E);
  static const Color success    = Color(0xFF4CAF50);
  static const Color danger     = Color(0xFFCF6679);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C3);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primary, secondary: secondary, surface: bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgCard, elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins', fontSize: 20,
        fontWeight: FontWeight.w600, color: textPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: bgCard, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2940), width: 0.5),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(bgElevated),
      dataRowColor: WidgetStatePropertyAll(bgCard),
    ),
  );
}
