import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material 3 theme with the design-system tokens layered on top.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.onSurface,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.recording,
  );

  bool selected(Set<WidgetState> states) => states.contains(WidgetState.selected);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cameraSurface,
      foregroundColor: AppColors.onCamera,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: AppSize.topBarHeight,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onCamera),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => selected(s) ? Colors.white : AppColors.switchOffThumb,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => selected(s) ? AppColors.primary : AppColors.switchOffTrack,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => selected(s) ? AppColors.primary : AppColors.switchOffThumb,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
      titleTextStyle: AppText.dialogTitle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.onSurface)),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
