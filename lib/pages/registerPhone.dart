import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for InputFormatters
import 'otp_authentication.dart';


class Registerphone extends StatefulWidget {
  const Registerphone({super.key});

  @override
  State<Registerphone> createState() => _RegisterphoneState();
}

class _RegisterphoneState extends State<Registerphone> {
  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff52677D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.19), // 10% horizontal padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.1), // 25% from the top

              // Main title
              Text(
                "Your phone number",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins-ExtraBold",
                  fontSize: 29.0,
                ),
              ),

              SizedBox(height: height * 0.010), // small spacing

              // Subtitle: Add this below the main title
              Text(
                "Please enter your number.",
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: 16.0,
                ),
              ),

              // new safeArea
             SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 1), // Adjust if needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.04),
                      Row(
                        children: [
                          // First grey box with border
                          SizedBox(
                            width: 69,
                            height: 38,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Main background container
                                Container(
                                  width: 69,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff1F2937),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                  ),
                                ),

                                // Layered grey border box
                                Positioned(
                                  left: 11, // adjust position within the main container
                                  top: 8,
                                  child: Container(
                                    width: 46,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xff767676),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),

                                // Text "+63" on top of the grey box
                                Positioned(
                                  left: 22, // slightly padded inside the grey box
                                  top: 11,
                                  child: Text(
                                    "+63",
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Spacer between the two SizedBox
                          SizedBox(width: 1), // You can adjust the width for more space

                          // Second SizedBox with light grey and a TextField
                          SizedBox(
                            width: 190, // Adjust as needed
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffE1E1E1),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "Phone number",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Button for submit
                      SizedBox(height: height * 0.02),

                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 81,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OtpAuthentication()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0F1A2B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            )



            ],
          ),
        ),
      ),
    );
  }
}


