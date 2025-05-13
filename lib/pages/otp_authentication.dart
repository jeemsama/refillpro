import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';

class OtpAuthentication extends StatefulWidget {
  final String email; // <-- Accept email

  const OtpAuthentication({super.key, required this.email});

  @override
  State<OtpAuthentication> createState() => _OtpAuthenticationState();
}

class _OtpAuthenticationState extends State<OtpAuthentication> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

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

              Text(
                "Enter the code we have sent to ${widget.email}.", // <-- Use email
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: height * 0.05),

              // OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: buildOtpBox(_otpControllers[index]),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 81,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      String otp = _otpControllers.map((c) => c.text).join();
                      // TODO: Validate the OTP with backend here before navigating
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
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

  Widget buildOtpBox(TextEditingController controller) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xffE1E1E1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && controller.selection.baseOffset == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
