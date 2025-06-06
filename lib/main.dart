import 'package:flutter/material.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/map.dart';
import 'package:refillproo/pages/activity.dart';
import 'package:refillproo/pages/profile.dart';
import 'package:refillproo/pages/register_email.dart';
import 'package:refillproo/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp(initialPage: SplashScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;
  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RefillPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: initialPage,
      routes: {
        '/home': (context) => const HomePage(),
        '/map': (context) => MapPage(),
        '/activity': (context) => const ActivityPage(),
        '/profile': (context) => const Profile(),
        '/register_email': (context) => const RegisterEmail()
      },
    );
  }
}
