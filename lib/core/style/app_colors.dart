import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDarkTextColor = Color(0xFF1A1A1A);
  static const Color secondaryDarkTextColor = Color.fromARGB(255, 96, 96, 96);
  static const Color lightBackgroundColor = Color(0xFFF5F7FB);

  static const Color primaryLightTextColor = Color(0xFFF5F7FB);
  static const Color secondaryLightTextColor = Color.fromARGB(
    255,
    100,
    100,
    100,
  );
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);

  static const Color primaryColor0 = Colors.red;
  static const Color primaryColor1 = Colors.green;
  static const Color primaryColor2 = Colors.blue;
  static const Color primaryColor3 = Colors.amber;
  static const Color primaryColor4 = Colors.purple;
  static const Color primaryColor5 = Colors.brown;
  static const Color primaryColor6 = Colors.indigo;

  static const double secA = 64 / 255;

  static Color secondaryColor0Light = Color.from(
    alpha: 1,
    red: (primaryColor0.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor0.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor0.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor1Light = Color.from(
    alpha: 1,
    red: (primaryColor1.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor1.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor1.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor2Light = Color.from(
    alpha: 1,
    red: (primaryColor2.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor2.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor2.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor3Light = Color.from(
    alpha: 1,
    red: (primaryColor3.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor3.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor3.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor4Light = Color.from(
    alpha: 1,
    red: (primaryColor4.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor4.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor4.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor5Light = Color.from(
    alpha: 1,
    red: (primaryColor5.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor5.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor5.b * secA + lightBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor6Light = Color.from(
    alpha: 1,
    red: (primaryColor6.r * secA + lightBackgroundColor.r * (1 - secA)),
    green: (primaryColor6.g * secA + lightBackgroundColor.g * (1 - secA)),
    blue: (primaryColor6.b * secA + lightBackgroundColor.b * (1 - secA)),
  );

  static Color secondaryColor0Dark = Color.from(
    alpha: 1,
    red: (primaryColor0.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor0.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor0.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor1Dark = Color.from(
    alpha: 1,
    red: (primaryColor1.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor1.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor1.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor2Dark = Color.from(
    alpha: 1,
    red: (primaryColor2.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor2.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor2.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor3Dark = Color.from(
    alpha: 1,
    red: (primaryColor3.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor3.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor3.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor4Dark = Color.from(
    alpha: 1,
    red: (primaryColor4.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor4.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor4.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor5Dark = Color.from(
    alpha: 1,
    red: (primaryColor5.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor5.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor5.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
  static Color secondaryColor6Dark = Color.from(
    alpha: 1,
    red: (primaryColor6.r * secA + darkBackgroundColor.r * (1 - secA)),
    green: (primaryColor6.g * secA + darkBackgroundColor.g * (1 - secA)),
    blue: (primaryColor6.b * secA + darkBackgroundColor.b * (1 - secA)),
  );
}
