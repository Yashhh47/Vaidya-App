import 'package:flutter/material.dart';
import 'package:sanjeevika/view/screens/auth/login_page.dart';

import '../../../utils/functions_uses.dart';
import 'package:get/get.dart';
import 'start_screen2.dart';

double size = SizeConfig.screenWidth;

class StartScreen3 extends StatefulWidget {
  @override
  State<StartScreen3> createState() => _StartScreen3State();
}

class _StartScreen3State extends State<StartScreen3> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFFFC8C8), // Light red at the top
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 3),

            // Logo Circle with Image
            Container(
              width: size / 3,
              padding: EdgeInsets.all(size / 35),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/shield.png',
                width: size / 4,
              ),
            ),

            SizedBox(height: size / 5),

            Text("Emergency Support", style: style_(fontSize: size / 20)),

            SizedBox(height: size / 30),

            Text(
                "Quick access to emergency contacts\n and medical history when needed",
                textAlign: TextAlign.center,
                style:
                    style_(fontSize: size / 25, fontWeight: FontWeight.w400)),

            Spacer(),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false),
                _buildDot(isActive: false),
                _buildDot(isActive: true),
              ],
            ),

            SizedBox(height: size / 18),

            // "Next" Button
            Padding(
              padding: EdgeInsets.only(bottom: size / 2),
              child: ElevatedButton(
                onPressed: () {
                  Get.off(LoginPage(),
                      transition: Transition.zoom,
                      duration: Duration(milliseconds: 350));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size / 5),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: size / 10, vertical: size / 25),
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: size / 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({
    required bool isActive,
  }) {
    return Container(
      width: size / 35,
      height: size / 35,
      margin: EdgeInsets.symmetric(horizontal: size / 70),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.red : Colors.grey[300],
      ),
    );
  }
}
