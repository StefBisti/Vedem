import 'package:flutter/foundation.dart';

class MiscUtils {
  static void debugPrint() {
    if (kDebugMode) {
      print('''
      ################################\n
      ################################\n
      ################################\n
      ################################\n
      ################################\n
    ''');
    }
  }

  static String formatDouble(double value) {
    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static double? parseDouble(String str) {
    if (str.isEmpty) return null;
    return double.tryParse(
      str.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.'),
    );
  }

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double invLerp(double min, double max, double val) =>
      (val - min) / (max - min);
}
