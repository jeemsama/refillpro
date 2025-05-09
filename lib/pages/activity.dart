import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Orders",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 1, // You can make this dynamic later
              itemBuilder: (context, index) => ActivityCard(
                shopName: "Nhorlen’s Water Station",
                dateTime: "21 Mar 2025, 9:35 AM",
                amount: 30.00,
                orderNumber: "ORDER-000$index",
                orderedBy: "John Doe",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String shopName;
  final String dateTime;
  final double amount;
  final String orderNumber;
  final String orderedBy;

  const ActivityCard({
    super.key,
    required this.shopName,
    required this.dateTime,
    required this.amount,
    required this.orderNumber,
    required this.orderedBy,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.95,
      height: screenHeight * 0.28,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Positioned(
            left: screenWidth * 0.025,
            top: 0,
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.24,
              decoration: ShapeDecoration(
                color: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * -0.06,
            top: screenHeight * 0.050,
            child: SizedBox(
              width: screenWidth * 0.4,
              child: const Text(
                '8:00 AM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.135,
            child: Container(
              width: screenWidth * 0.1,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/dispenser_gallon.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.22,
            top: screenHeight * 0.135,
            child: Container(
              width: screenWidth * 0.08,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/regular_gallon.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.255,
            top: screenHeight * 0.21,
            child: const Text(
              'x2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.12,
            top: screenHeight * 0.21,
            child: const Text(
              'x2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.01,
            child: Text(
              orderedBy,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.035,
            child: const Text(
              '0912-3234-234',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.064,
            child: const Text(
              'Borrow gallon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.09,
            child: SizedBox(
              width: screenWidth * 0.3,
              child: const Text(
                'Message here Message hereMessage hereMessage hereMessage hereMessage ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.65,
            top: screenHeight * 0.155,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order cancelled")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA62C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                minimumSize: Size(screenWidth * 0.2, screenHeight * 0.03),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Cancel order',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.69,
            top: screenHeight * 0.20,
            child: Text(
              '₱${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
  left: screenWidth * 0.66,
  top: screenHeight * 0.03,
  child: Row(
    children: const [
      Text(
        'Pending',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(width: 4),
      Icon(
        Icons.access_time, // or any other icon you prefer
        color: Colors.white,
        size: 16,
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}
