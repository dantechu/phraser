import 'package:flutter/material.dart';

import '../util/colors.dart';

class ThemeStyles {

  static final lightTheme = ThemeData(fontFamily: 'Kanit').copyWith(
    primaryColor: kPrimaryColor,
    primaryColorDark: Colors.black,
    primaryColorLight: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      color: kPrimaryColor,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kPrimaryColor,
      selectedItemColor: Color(0xFFFFFFFF),
      unselectedItemColor: Colors.grey.shade900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(kButtonColor),
        foregroundColor: MaterialStateProperty.all(kButtonTextColor),

        elevation: MaterialStateProperty.all(0),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      elevation: 10,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: kPrimaryColor,
      margin: const EdgeInsets.all(10),
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.grey.shade900,
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColorDark: Colors.white,
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Kanit',
    ),
    primaryTextTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Kanit',
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: Colors.grey.shade800,
      elevation: 2,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade800,
      selectedItemColor: Colors.white,
      unselectedItemColor: kPrimaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade800),
        elevation: MaterialStateProperty.all(10),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey.shade900,
      elevation: 10,
    ),
    cardTheme: CardThemeData(
      color: Colors.grey.shade800,
      elevation: 0,
      margin: const EdgeInsets.all(10),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.white),
      trackColor: MaterialStateProperty.all(Colors.grey.shade900),
    ),
  );
}
