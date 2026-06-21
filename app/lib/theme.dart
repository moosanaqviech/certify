import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF0A0B11);
  static const Color bgTint = Color(0xFF191B2C);
  static const Color frame = Color(0xFF13141F);
  static const Color surface = Color(0xFF161822);
  static const Color surfaceRaised = Color(0xFF1E2130);
  static const Color ink = Color(0xFFF1F1F6);
  static const Color inkSoft = Color(0xFFA6A8B6);
  static const Color inkFaint = Color(0xFF62647A);
  static const Color hairline = Color(0x14FFFFFF);
  static const Color accent = Color(0xFF7C8CF8);

  // Per-cert
  static const Color databricksAccent = Color(0xFF8D7BF6);
  static const Color databricksInk = Color(0xFFB4A9FF);
  static const Color snowflakeAccent = Color(0xFF5EC8C0);
  static const Color snowflakeInk = Color(0xFF7FD8D0);
  static const Color dbtAccent = Color(0xFF7C8CF8);
  static const Color dbtInk = Color(0xFF9AA6FB);

  static TextStyle display({
    double size = 36,
    FontWeight weight = FontWeight.w600,
    Color color = ink,
    double? height,
    double letterSpacing = -0.02,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: size * letterSpacing,
      fontStyle: style,
    );
  }

  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = inkFaint,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle label({
    double size = 11.5,
    Color color = inkFaint,
  }) {
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: size * 0.14,
    );
  }

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
      ),
      textTheme: GoogleFonts.hankenGroteskTextTheme(ThemeData.dark().textTheme),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
