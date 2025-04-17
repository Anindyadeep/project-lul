import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/waitlist_screen.dart';
import 'screens/recommendations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const DateMeApp());
}

class DateMeApp extends StatelessWidget {
  const DateMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: "DateMe",
          theme: ThemeData(
            primarySwatch: Colors.pink,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/waitlist': (context) => const WaitlistScreen(),
            '/recommendations': (context) => const RecommendationsScreen(),
          },
        );
      },
    );
  }
}
