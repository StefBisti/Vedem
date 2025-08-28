import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

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

  static Future<void> dumpDatabaseToConsole(Database db) async {
    if (kDebugMode == false) return;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    for (final row in tables) {
      final table = row['name'] as String;
      final rows = await db.query(table);
      if (kDebugMode) {
        print('--- TABLE: $table (${rows.length} rows) ---');
      }
      for (final r in rows) {
        if (kDebugMode) {
          print(r); // Map<String, dynamic>
        }
      }
    }
  }

  static void showSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(content)));
  }
}
