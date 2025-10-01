import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:vedem/core/pages/day_page.dart';
import 'package:vedem/core/style/app_themes.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/init_dependencies.dart';

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await serviceLocator.allReady(timeout: Duration(seconds: 3));
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});
  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late final KeyboardVisibilityController _keyboardVisibilityController;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityController = KeyboardVisibilityController();

    _keyboardSubscription = _keyboardVisibilityController.onChange.listen((
      bool visible,
    ) {
      if (!visible) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vedem',
      theme: AppThemes.lightTheme,
      home: DayPage(dayId: TimeUtils.thisDayId),
    );
  }
}
