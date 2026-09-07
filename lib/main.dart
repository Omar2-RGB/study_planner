import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // حزمة الإعلانات

import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  // ضروري جداً لضمان عمل ربط الإعلانات وفلاتر بشكل سليم قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة منصة الإعلانات لجوجل AdMob
  await MobileAds.instance.initialize();

  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFFFF9800),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFF1A1A1A), fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}