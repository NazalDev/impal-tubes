import 'package:flutter/material.dart';
import 'package:volync/core/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(16),
      );

  static final lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: AppPallete.whiteColor,
        backgroundColor: AppPallete.buttonColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      //styles
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      errorStyle: const TextStyle(fontSize: 12),

      prefixIconColor: Colors.black54,
      suffixIconColor: Colors.black54,

      filled: true,
      fillColor: AppPallete.whiteColor,

      //border
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.focusedColor),
      errorBorder: _border(AppPallete.errorColor),
      focusedErrorBorder: _border(AppPallete.errorColor),
    ),
  );
}
