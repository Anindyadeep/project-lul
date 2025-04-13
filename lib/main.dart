import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DateMeApp());
}

class DateMeApp extends StatelessWidget {
  const DateMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DateMe",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
