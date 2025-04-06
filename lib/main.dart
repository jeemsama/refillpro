import 'package:flutter/material.dart';
import 'package:refillproo/pages/onboarding.dart'; // Ensure this import path is correct
import 'package:refillproo/pages/otp_authentication.dart';
import 'package:refillproo/pages/registerPhone.dart'; // Ensure this import path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Onboarding(), // Starting with Onboarding screen
    );
  }
}
