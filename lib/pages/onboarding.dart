import 'package:flutter/material.dart';
import 'register_phone.dart'; // Ensure this import is correct

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  void initState() {
    super.initState();

    // Add the 3-second delay before navigating
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the Registerphone screen after 3 seconds
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  const Registerphone()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff52677D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "images/logo.png",
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width / 1,
                ),
                const SizedBox(height: 0.4),
                const Text(
                  "Easy refills, anytime, anywhere.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    fontFamily: "Poppins",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
