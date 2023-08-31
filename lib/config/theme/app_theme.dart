import 'package:flutter/material.dart';

class AppTheme {
   ThemeData get themeData => ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.red,
    visualDensity: VisualDensity.adaptivePlatformDensity);
}