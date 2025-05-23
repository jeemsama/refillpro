import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp_authentication.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  State<RegisterEmail> createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // No trailing slash!
  static const String _baseUrl = 'http://192.168.1.6:8000';

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final url = Uri.parse('$_baseUrl/api/customer/send-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpAuthentication(email: email),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Failed to send OTP')),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff52677D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your email address',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins-ExtraBold',
                  fontSize: 26.0,
                ),
              ),
              SizedBox(height: height * 0.01),
              const Text(
                'Please enter your email to receive an OTP.',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: height * 0.04),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xffE1E1E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email address',
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
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0F1A2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
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
}
