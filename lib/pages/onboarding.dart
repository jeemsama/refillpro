import 'package:flutter/material.dart';
import 'register_phone.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "images/logo2.png",
      "title": "Welcome",
      "subtitle": "Easy refills, anytime, anywhere.",
    },
    {
      "image": "images/slide2.png",
      "title": "Locate Nearby Stations",
      "subtitle": "Quickly find your preferred water station for delivery.",
    },
    {
      "image": "images/slide3.png",
      "title": "User-Friendly Interface",
      "subtitle": "Enjoy a simple and intuitive app experience.",
    },
    {
      "image": "images/slide4.png",
      "title": "Get Started",
      "subtitle": "Join us and simplify your refills!",
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterEmail()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff52677D),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildImageWithBlob(
                          _onboardingData[index]["image"]!,
                          index,
                          context,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _onboardingData[index]["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["subtitle"]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_onboardingData.length, (index) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Color(0xFF1F2937) : Colors.white38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F2937),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithBlob(String imagePath, int index, BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.35;

    if (index == 0) {
      return Center(
        child: Image.asset(
          imagePath,
          height: imageHeight,
        ),
      );
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(imageHeight + 60, imageHeight + 60),
            painter: JellyBlobPainter(index),
          ),
          Image.asset(
            imagePath,
            height: imageHeight,
          ),
        ],
      ),
    );
  }
}

// ✅ Painter to draw soft jelly-like blobs
class JellyBlobPainter extends CustomPainter {
  final int index;

  JellyBlobPainter(this.index);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1F2937).withAlpha(90);

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (index == 1) {
      // Slight drop/jelly
      path.moveTo(w * 0.5, 0);
      path.cubicTo(w * 0.9, 0, w, h * 0.3, w, h * 0.5);
      path.cubicTo(w, h * 0.8, w * 0.7, h, w * 0.5, h);
      path.cubicTo(w * 0.3, h, 0, h * 0.8, 0, h * 0.5);
      path.cubicTo(0, h * 0.3, w * 0.1, 0, w * 0.5, 0);
    } else if (index == 2) {
      // Puffed jelly blob
      path.moveTo(w * 0.4, 0);
      path.cubicTo(w * 0.8, 0, w, h * 0.2, w, h * 0.4);
      path.cubicTo(w, h * 0.8, w * 0.6, h, w * 0.4, h);
      path.cubicTo(w * 0.1, h, 0, h * 0.8, 0, h * 0.5);
      path.cubicTo(0, h * 0.2, w * 0.1, 0, w * 0.4, 0);
    } else {
  // Slide 4 - Jelly-like rounded blob
  path.moveTo(w * 0.5, 0);
  path.cubicTo(w * 0.8, 0, w, h * 0.2, w, h * 0.3);
  path.cubicTo(w, h * 0.8, w * 0.8, h, w * 0.5, h);
  path.cubicTo(w * 0.4, h, 0, h * 0.8, 0, h * 0.5);
  path.cubicTo(0, h * 0.3, w * 0.2, 0, w * 0.4, 0);
}


    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
