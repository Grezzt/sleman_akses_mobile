import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    );
  }
}
