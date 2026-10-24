import 'package:flutter/material.dart';

/// Design tokens — see v2/design_system/README.md. Values were sampled from
/// the reference/ screenshots; replace with Figma source values when known.
abstract final class AppColors {
  static const primary = Color(0xFFFB7F87);
  static const primarySoft = Color(0xFFFDD0D3);
  static const primaryTint = Color(0xFFFFF5F6);
  static const chipSelected = Color(0xFFF8C6BF);
  static const cameraSurface = Color(0xFF231F1F);
  static const onCamera = Color(0xFFFFFFFF);
  static const onCameraMuted = Color(0xFFBDB7B6);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1D1B1B);
  static const onSurfaceMuted = Color(0xFF6F6A6A);
  static const switchOffTrack = Color(0xFFF2E9EA);
  static const switchOffThumb = Color(0xFF8F8586);
  static const inputFill = Color(0xFFF2F0F0);
  static const placeholder = Color(0xFF3A3434);
  static const scrim = Color(0x80000000);
  static const recording = Color(0xFFE53935);
}

abstract final class AppSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

abstract final class AppSize {
  static const double topBarHeight = 56;
  static const double listRowHeight = 56;
  static const double shutterSize = 72;
  static const double shutterRing = 4;
  static const double sideButtonSize = 44;
  static const double swipeActionWidth = 48;
  static const double chipBarHeight = 48;
  static const double railWidth = 56;
  static const double expandedControlsWidth = 104;

  /// Width at which the foldable "expanded" layout kicks in (screens.md §7).
  static const double expandedBreakpoint = 600;
}

abstract final class AppRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 28;
  static const double pill = 999;
}

abstract final class AppText {
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface);
  static const dialogTitle = TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.onSurface);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.onSurface);
  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceMuted);
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const swipe = Duration(milliseconds: 200);
  static const snap = Duration(milliseconds: 250);
}
