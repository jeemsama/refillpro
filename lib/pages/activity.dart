import 'package:flutter/material.dart';
import 'package:refillproo/navs/bottom_nav.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        // Already on Activity
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: const Center(child: Text('Activity Page')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
}
