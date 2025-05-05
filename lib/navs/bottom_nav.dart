import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // List of icons for the navbar
  final List<IconData> navIcons = [
    Icons.home,   // Home/Dashboard icon
    Icons.map_outlined,        // Map/Navigation icon
    Icons.history,       // Cart/Shop icon
    Icons.person_outline,      // Profile icon
  ];

  @override
  Widget build(BuildContext context) {
    // Get device screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    
    // Determine navbar width based on screen width
    final double navBarWidth = _getResponsiveWidth(screenSize.width);
    
    // Determine navbar height based on screen height
    final double navBarHeight = _getResponsiveHeight(screenSize.height);
    
    // Determine icon size based on screen size
    final double iconSize = _getResponsiveIconSize(screenSize);

    return Container(
      alignment: Alignment.center,
      child: Container(
        width: navBarWidth,
        height: navBarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(navBarHeight / 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            navIcons.length,
            (index) => _buildNavItem(navIcons[index], index, iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, double iconSize) {
    final bool isSelected = widget.selectedIndex == index;
    
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.8,
        child: Container(
          width: iconSize * 1.5,
          height: iconSize * 1.5,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(iconSize / 2),
          ),
          child: Icon(
            icon,
            color: isSelected ? Color(0xff1F2937) : Colors.grey,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  // Responsive width calculation
  double _getResponsiveWidth(double screenWidth) {
    // For small phones
    if (screenWidth < 360) {
      return screenWidth * 0.85;
    }
    // For regular phones
    else if (screenWidth < 600) {
      return screenWidth * 0.82;
    }
    // For small tablets
    else if (screenWidth < 768) {
      return screenWidth * 0.7;
    }
    // For large tablets and iPads
    else if (screenWidth < 1024) {
      return screenWidth * 0.6;
    }
    // For larger screens, cap the max width
    else {
      return 500;
    }
  }

  // Responsive height calculation
  double _getResponsiveHeight(double screenHeight) {
    // For smaller phones
    if (screenHeight < 700) {
      return 60;
    }
    // For regular phones
    else if (screenHeight < 900) {
      return 67;
    }
    // For tablets and iPads
    else if (screenHeight < 1200) {
      return 75;
    }
    // For larger screens
    else {
      return 85;
    }
  }

  // Responsive icon size calculation
  double _getResponsiveIconSize(Size screenSize) {
    // Consider both width and height for the best proportion
    final double smallerDimension = screenSize.width < screenSize.height 
        ? screenSize.width 
        : screenSize.height;
    
    // For very small phones
    if (smallerDimension < 360) {
      return 20;
    }
    // For regular phones
    else if (smallerDimension < 600) {
      return 24;
    }
    // For tablets and iPads
    else if (smallerDimension < 900) {
      return 28;
    }
    // For larger screens
    else {
      return 32;
    }
  }
}