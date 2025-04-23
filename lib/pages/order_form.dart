import 'package:flutter/material.dart';
// import 'map.dart';


class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  // Selected time slot
  String? selectedTimeSlot;

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    nameController.dispose();
    phoneController.dispose();
    instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Define colors
    const backgroundColor = Color(0xFF455567);
    const darkBlue = Color(0xFF0F1A2B);
    const borderColor = Color(0xFF1F2937);
    const textColor = Color(0xFFE5E7EB);
    const unselectedColor = Color(0xFF1F2937);
    const inputColor = Color(0xFFD9D9D9);
    const timeSlotSelectedColor = Color(0xFFc6c6c6);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Header with back button and title
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: textColor,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.00),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Order form',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Please enter complete details.',
                          style: TextStyle(
                            color: textColor,
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Recipients Info Container
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'Recipients Info',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Name field
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: Text(
                            'Name:',
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.04,
                            decoration: BoxDecoration(
                              color: inputColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Phone field
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: Text(
                            'Phone:',
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.04,
                            decoration: BoxDecoration(
                              color: inputColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Instruction field
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: Text(
                            'Instruction:',
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.04,
                            decoration: BoxDecoration(
                              color: inputColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: instructionController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Location label
                    Text(
                      'Pin your location',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Map placeholder
                    Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/map_placeholder.png', // Replace with your actual map placeholder
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1F2937).withAlpha(128),
                              child: Center(
                                child: Icon(
                                  Icons.map,
                                  size: screenWidth * 0.2,
                                  color: Colors.white.withAlpha(77),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.01),
              
              // Delivery Info Container
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.all(screenWidth * 0.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'Delivery Info',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Time slot selection label
                    Text(
                      'Select delivery time slots',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Time slot buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimeSlotButton('8am', screenWidth, screenHeight, timeSlotSelectedColor, unselectedColor),
                        _buildTimeSlotButton('11am', screenWidth, screenHeight, timeSlotSelectedColor, unselectedColor),
                        _buildTimeSlotButton('2pm', screenWidth, screenHeight, timeSlotSelectedColor, unselectedColor),
                        _buildTimeSlotButton('5pm', screenWidth, screenHeight, timeSlotSelectedColor, unselectedColor),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Divider
                    Container(
                      width: screenWidth * 0.8,
                      height: 1,
                      color: borderColor,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Payment method
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Payment method:',
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Cash On Delivery',
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    
                    // Space for future content
                    SizedBox(height: screenHeight * 0.08),
                    
                    // Bottom divider
                    Container(
                      width: screenWidth * 0.8,
                      height: 1,
                      color: borderColor,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Total and Place Order button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Total: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '₱30.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Space for your function later
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const MapPage(showDialogOnLoad: true)),
                              
                            // );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );

  }
  
  // Helper method to build time slot buttons
  Widget _buildTimeSlotButton(String time, double screenWidth, double screenHeight, Color selectedColor, Color unselectedColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeSlot = time;
        });
      },
      child: Container(
        width: screenWidth * 0.16,
        height: screenHeight * 0.045,
        decoration: BoxDecoration(
          color: selectedTimeSlot == time ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
