import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff52677D),
      body: Container(child: Column(children: [
        // Stack(children: [Positioned(left: 20, top: 230, child: Image.asset("images/logo.png", height: MediaQuery.of(context).size.height/2, width: MediaQuery.of(context).size.width/2, fit: BoxFit.cover,))],),
        Center(child: Image.asset("images/logo.png", height: MediaQuery.of(context).size.height/2, width: MediaQuery.of(context).size.width/2, fit: BoxFit.cover,)),
        Text("Easy refills, anytime, anywhere.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0, fontFamily: "Poppins"),)
      ],),)
    );
  }
}