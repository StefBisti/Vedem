import 'package:flutter/material.dart';
import 'package:vedem/core/pages/day_page.dart';
import 'package:vedem/core/style/app_themes.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await serviceLocator.allReady(timeout: Duration(seconds: 3));
  MiscUtils.dumpDatabaseToConsole(serviceLocator());
  runApp(const MainApp());
}

// add get all tasks

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vedem',
      theme: AppThemes.theme,
      home: DayPage(dayId: '2025-08-27'),
    );
  }
}
