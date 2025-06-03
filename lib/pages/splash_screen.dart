import 'package:flutter/material.dart';
import 'package:refillproo/pages/onboarding.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/register_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    final remember = prefs.getBool('remember_device') ?? false;

    final nextPage = token != null
        ? (remember ? const HomePage() : const RegisterEmail())
        : const Onboarding();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF455567),
      body: Center(
        child: Image.asset(
          'images/logo2.png',
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }
}
