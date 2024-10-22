import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData( 
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed( 
    seedColor: const Color.fromARGB(255, 97, 255, 123),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 97, 255, 123),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
