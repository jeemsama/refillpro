import 'package:flutter/material.dart';
import 'package:refillproo/navs/bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 3:
        // Already on Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
}
