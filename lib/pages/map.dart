import 'package:flutter/material.dart';
import 'package:refillproo/navs/bottom_nav.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on Map
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
      appBar: AppBar(title: const Text('Map')),
      body: const Center(child: Text('Map Page')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
}
