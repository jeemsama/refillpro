import 'package:flutter/material.dart';
import 'package:refillproo/pages/onboarding.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/map.dart';
import 'package:refillproo/pages/activity.dart';
import 'package:refillproo/pages/profile.dart';
import 'package:refillproo/pages/register_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('customer_token');
  final remember = prefs.getBool('remember_device') ?? false;

  final initialPage = token != null
      ? (remember ? const HomePage() : const RegisterEmail())
      : const Onboarding();

  runApp(MyApp(initialPage: initialPage));

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
        '/map': (context) => const MapPage(),
        '/activity': (context) => const ActivityPage(),
        '/profile': (context) => const Profile(),
        '/register_email': (context) => const RegisterEmail()
      },
    );
  }
}
