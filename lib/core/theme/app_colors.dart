import 'package:flutter/material.dart';

class AppColors {
  // Deep obsidian background colors (MONOCHROME)
  static const Color background = Color(0xFF0A0A0A);
  static const Color primaryContainer = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF111111);
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color surfaceCardLight = Color(0xFF242424);
  static const Color surfaceContainer = Color(0xFF1E1E1E);
  static const Color surfaceContainerLowest = Color(0xFF080808);
  static const Color surfaceVariant = Color(0xFF2E2E2E);
  static const Color outlineVariant = Color(0xFF3D3D3D);

  // Monochrome Accents — whites & grays only
  static const Color credPink = Color(0xFFFFFFFF);       // was pink → white
  static const Color credPinkGlow = Color(0x22FFFFFF);
  static const Color cyberTeal = Color(0xFFD4D4D4);      // was teal → light gray
  static const Color cyanAccent = Color(0xFFFFFFFF);     // was cyan → white
  static const Color cyanGlow = Color(0x18FFFFFF);
  static const Color neonPurple = Color(0xFFAAAAAA);     // was purple → gray
  static const Color electricGold = Color(0xFFE0E0E0);   // was gold → light gray
  static const Color vividBlue = Color(0xFFBBBBBB);      // was blue → gray
  static const Color urgentRed = Color(0xFFFFFFFF);      // was red → white

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF909090);
  static const Color onSurfaceVariant = Color(0xFF909090);
  static const Color textMuted = Color(0xFF606060);

  // Status Badge Colors — all monochrome shades
  static const Color statusDiscovered = Color(0xFF888888);
  static const Color statusApplied = Color(0xFFAAAAAA);
  static const Color statusShortlisted = Color(0xFFE0E0E0);
  static const Color statusInterview = Color(0xFFCCCCCC);
  static const Color statusOffer = Color(0xFFFFFFFF);

  // Monochrome Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F1F1F),
      Color(0xFF131313),
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF222222),
      Color(0xFF111111),
    ],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF444444), Color(0xFF2A2A2A)],
  );
}
