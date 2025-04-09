import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: const Color(0xFF52677D),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 10,
            height: 10,
            child: Icon(Icons.home),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 10,
            height: 10,
            child: Icon(Icons.map),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 10,
            height: 10,
            child: Icon(Icons.history),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 10,
            height: 10,
            child: Icon(Icons.person),
          ),
          label: '',
        ),
      ],
    );
  }
}
