import 'package:flutter/material.dart';

/// A simple white header widget with drop shadow.
///
/// This header provides a clean white bar with a subtle drop shadow,
/// matching the provided design.
class AppHeader extends StatelessWidget {
  /// Height of the header. Defaults to 78.
  final double height;

  /// Color of the header. Defaults to white.
  final Color backgroundColor;

  /// Creates an instance of [AppHeader].
  const AppHeader({
    super.key,
    this.height = 78.0,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

