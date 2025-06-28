import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/screens/onboarding/getstarted_screen.dart';
import 'package:sanjeevika/view/widgets/common/loading_screen.dart';
import '../home/home_page.dart';
import '../../../utils/functions_uses.dart';
import '../../../services/auth_functions.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Datacontroller data;
  @override
  void initState() {
    super.initState();
    data = Get.find<Datacontroller>();
  }

  final formKey = GlobalKey<FormState>();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool codeSent = false;
  String? _verificationId;
  bool otpSent = false;

  void sendOTP() {
    final phone = "+91${phoneController.text.trim()}";
    _phoneAuthService.verifyPhoneNumber(
      phoneNumber: phone,
      codeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          codeSent = true;
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  void verifyOTP() async {
    if (_verificationId != null && otpController.text.trim().length == 6) {
      Get.dialog(loading_screen());
      final user = await _phoneAuthService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );
        navigateWithLoading();
      }
    }
  }

  void googlesignin() async {
    final usercredential = await signInWithGoogle();
    if (usercredential != null) {
      final user = usercredential.user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in user as ${user!.displayName}')),
      );

      data.set_patient_email(user!.email.toString());

      Get.off(getstartedscreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in cancelled or failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFDFF4D9),
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size / 4),
                Image.asset(
                  'assets/images/sanjeevikalogo.png',
                  width: size / 4,
                ),
                SizedBox(height: size / 15),
                Text(
                  'Sanjeevika',
                  style: style_(
                    fontSize: size / 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(height: size / 16),
                Text(
                  'Simplifying medication tracking and health support\n— smartly and safely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff609447),
                  ),
                ),
                SizedBox(height: size / 12),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: size / 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: size / 35),
                      Text(
                        'Enter Phone number',
                        style: TextStyle(
                          fontSize: size / 25,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: size / 35,
                      ),
                      TextFormField(
                        controller: phoneController,
                        enabled: !codeSent, // Disable when code is sent
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size / 20),
                              borderSide: BorderSide(
                                color: Colors.green.shade800,
                                width: 2.0,
                              )),
                          filled: true,
                          fillColor:
                              codeSent ? Colors.grey.shade100 : Colors.white,
                          hintText: "+91",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size / 20),
                          ),
                          suffixIcon: phoneController.text.isNotEmpty &&
                                  !codeSent
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      phoneController.clear();
                                    });
                                  },
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {}); // Refresh to show/hide clear button
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          } else if (value.toString().length != 10)
                            return "Please enter a valid phone number";
                        },
                      ),
                      SizedBox(height: size / 30),
                      if (!codeSent)
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() => codeSent = true);
                              sendOTP();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            minimumSize: Size(double.infinity, size / 9),
                            backgroundColor: Color(0xff00A901),
                          ),
                          child: Text(
                            "Send Verification Code",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: size / 25),
                          ),
                        ),
                      if (codeSent) ...[
                        SizedBox(height: size / 20),
                        Row(
                          children: [
                            Text(
                              "Code sent to +91 ${phoneController.text}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(width: size / 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  codeSent = false;
                                  phoneController.clear();
                                  otpController.clear();
                                });
                              },
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size / 40),
                        TextFormField(
                          controller: otpController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Enter OTP",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(size / 20),
                            ),
                            suffixIcon: otpController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        otpController.clear();
                                      });
                                    },
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                  )
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(
                                () {}); // Refresh to show/hide clear button
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size / 30),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              verifyOTP();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff00A901),
                            minimumSize: Size(double.infinity, size / 9),
                          ),
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      SizedBox(height: size / 30),
                      Center(
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: size / 25,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: size / 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, size / 9),
                        ),
                        onPressed: () {
                          googlesignin();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              width: size / 20,
                            ),
                            SizedBox(
                              height: 0,
                              width: size / 35,
                            ),
                            Text(
                              'Sign in with Google',
                              style: style_(
                                color: Colors.grey.shade600,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void navigateWithLoading() async {
  // Show the loading screen as a full dialog
  Get.dialog(
    loading_screen(),
    barrierDismissible: false,
  );

  // Wait for 3 seconds (or any async task)
  await Future.delayed(const Duration(seconds: 3));

  // Close the loading dialog
  Get.back();

  Get.off(() => getstartedscreen(),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 350));
}
