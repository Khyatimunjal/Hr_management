import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'post_login.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _generatedOtp = '';

  @override
  void initState() {
    super.initState();
    _generatedOtp = _generateOtp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _generateOtp() {
    Random random = Random();
    return random.nextInt(10000).toString().padLeft(4, '0');
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showOtpField = false;
  bool _otpSent = false;

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      String recipientEmail = _emailController.text.trim();

      String username = 'khyatim03@gmail.com';
      final smtpServer = SmtpServer('sandbox.smtp.mailtrap.io',
          username: '9f6fc7b152a64c', password: '4b90db4f45719b', port: 2525);

      final message = Message()
        ..from = Address(username, 'Khyati')
        ..recipients.add(recipientEmail)
        ..subject = 'OTP Verification'
        ..text = 'Your OTP is: $_generatedOtp';

      try {
        final sendReport = await send(message, smtpServer);
        debugPrint('Message sent:');
        setState(() {
          _otpSent = true;
          _showOtpField = true;
        });
      } catch (e) {
        debugPrint('Error occurred while sending OTP: $e');
      }
    }
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      String enteredotp = _otpController.text.trim();
      debugPrint('Entered OTP: $enteredotp');
      if (enteredotp == _generatedOtp) {
        debugPrint('OTP verification successful');
        _showLoginSuccessDialog();
      } else {
        debugPrint('OTP verification failed');
      }
    }
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OTP Verification'),
          content: const Text('OTP verification successful!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                String email = _emailController.text.trim();
                String otp = _otpController.text.trim();
                final user = User(email: email, password: otp);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostLogin(
                            user: user,
                          )),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailController.text.isEmpty
                      ? 'Email is required'
                      : null,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Visibility(
                visible: !_otpSent,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text('Send OTP'),
                ),
              ),
              Visibility(
                visible: _showOtpField,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        errorText: _otpController.text.isEmpty
                            ? 'OTP is required'
                            : null,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'OTP is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _verifyOtp();
                        final otp = OTP(
                            email: _emailController.text,
                            otp: _otpController.text);
                        createOtp(otp);
                      },
                      child: const Text('Verify OTP'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future createOtp(OTP otp) async {
  final docOtp = FirebaseFirestore.instance.collection('forgot password').doc();
  otp.id = docOtp.id;

  final json = otp.toJson();
  await docOtp.set(json);
}

class OTP {
  String id;
  final String email;
  final String otp;

  OTP({
    this.id = '',
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}
