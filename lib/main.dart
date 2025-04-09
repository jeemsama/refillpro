import 'package:flutter/material.dart';
import 'package:refillproo/pages/onboarding.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/map.dart';
import 'package:refillproo/pages/activity.dart';
import 'package:refillproo/pages/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RefillPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/home': (context) => const HomePage(),
        '/map': (context) => const MapPage(),
        '/activity': (context) => const ActivityPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
