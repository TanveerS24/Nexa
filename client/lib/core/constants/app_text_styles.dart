import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // App Title / Brand
  static TextStyle brandTitle = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
  );

  // Greeting
  static TextStyle greetingLabel = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  static TextStyle greetingName = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle greetingSubtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: -0.2,
  );

  // Section Header Prompt
  static TextStyle promptTitle = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    height: 1.15,
    letterSpacing: -0.8,
  );

  // Card Typography
  static TextStyle cardTitle(Color color) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle cardSubtitle(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.35,
      );

  static TextStyle cardPill(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  // Action Button
  static TextStyle exploreAction = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: -0.3,
  );

  // Notifications
  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -0.4,
  );

  static TextStyle viewAll = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle notificationTitle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -0.2,
  );

  static TextStyle notificationSubtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle notificationTimestamp = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Bottom Nav
  static TextStyle navActive = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.navActiveText,
  );

  static TextStyle navInactive = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.navInactive,
  );
}
