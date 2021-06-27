import 'package:flutter/material.dart';
import 'package:venus_robusta/util/colors.dart';

mixin themeData {
  static Color goldAccent = CoresHexdecimal("bb52d1");
  static Color whiteColor = Colors.white;
  static Color primaryColor = Colors.grey;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: CoresHexdecimal("bb52d1"),
    primarySwatch: primaryColor,
    primaryColor: CoresHexdecimal("bb52d1"),
    appBarTheme: AppBarTheme(
      actionsIconTheme: new IconThemeData(color: goldAccent),
      iconTheme: new IconThemeData(color: CoresHexdecimal("bb52d1")),
      textTheme: TextTheme(
          headline6: TextStyle(
              color: goldAccent, fontWeight: FontWeight.w500, fontSize: 17.0)),
      color: whiteColor,
      elevation: 3.0,
      titleTextStyle: TextStyle(
          color: goldAccent, fontWeight: FontWeight.w500, fontSize: 17.0),
    ),
    accentColor: goldAccent,
    // ignore: deprecated_member_use
    cursorColor: goldAccent,
    toggleableActiveColor: goldAccent,
    scaffoldBackgroundColor: whiteColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xff121212),
    primarySwatch: primaryColor,
    primaryColor: Color(0xff1f1f1f),
    appBarTheme: AppBarTheme(
      iconTheme: new IconThemeData(color: CoresHexdecimal("bb52d1")),
      textTheme: TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0)),
    ),
    cardColor: Color(0xff1f1f1f),
    accentColor: goldAccent,
    scaffoldBackgroundColor: Color(0xff121212),
    // ignore: deprecated_member_use
    cursorColor: goldAccent,
    toggleableActiveColor: goldAccent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
