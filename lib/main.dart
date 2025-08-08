import 'package:flutter/material.dart';
import 'package:server_scanning/screens/home_screen.dart';
import 'package:server_scanning/utils/colors.dart';

void main() {
  runApp(const LEDScannerApp());
}

class LEDScannerApp extends StatelessWidget {
  const LEDScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network LED Scanner',
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterial,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.background,
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
