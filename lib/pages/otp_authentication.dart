import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpAuthentication extends StatefulWidget {
  @override
  State<OtpAuthentication> createState() => _OtpAuthenticationState();
}

class _OtpAuthenticationState extends State<OtpAuthentication> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff52677D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.1),

              // Title
              Text(
                "Check your messages",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins-ExtraBold",
                  fontSize: 29.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),

              SizedBox(height: height * 0.010),

              // Subtitle
              Text(
                "Enter the code we have sent to your number.",
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: height * 0.05),

              // Four OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildOtpBox(),
                  SizedBox(width: 5),
                  buildOtpBox(),
                  SizedBox(width: 5),
                  buildOtpBox(),
                  SizedBox(width: 5),
                  buildOtpBox(),
                ],
              ),

              SizedBox(height: height * 0.02),

              // Submit button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 81,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Submitted");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0F1A2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable OTP box
  Widget buildOtpBox() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xffE1E1E1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
