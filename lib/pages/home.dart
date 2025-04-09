import 'package:flutter/material.dart';
import 'package:refillproo/navs/bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
}
