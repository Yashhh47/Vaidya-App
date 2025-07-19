import 'package:flutter/material.dart';

import 'start_screen3.dart';
import '../../../utils/functions_uses.dart';
import 'package:get/get.dart';

double size = SizeConfig.screenWidth;

class StartScreen2 extends StatefulWidget {
  const StartScreen2({super.key});

  @override
  State<StartScreen2> createState() => _StartScreen2State();
}

class _StartScreen2State extends State<StartScreen2> {
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
              Color(0xFFC8FFD9), // Light green at the top
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
                  shape: BoxShape.circle, color: Colors.transparent),
              child: Image.asset(
                'assets/images/comment.png',
              ),
            ),

            SizedBox(height: size / 5),

            Text("AI Health Assistant", style: style_(fontSize: size / 20)),

            SizedBox(height: size / 30),

            Text(
                "Get instant answers to your health\n questions with our smart chatbot",
                textAlign: TextAlign.center,
                style:
                    style_(fontSize: size / 25, fontWeight: FontWeight.w400)),

            Spacer(),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false),
                _buildDot(isActive: true),
                _buildDot(isActive: false),
              ],
            ),

            SizedBox(height: size / 18),

            // "Next" Button
            Padding(
              padding: EdgeInsets.only(bottom: size / 2),
              child: ElevatedButton(
                onPressed: () {
                  Get.off(StartScreen3(),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 350));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size / 5),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: size / 10, vertical: size / 25),
                ),
                child: Text(
                  "Next",
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
        color: isActive ? Color(0xFF4CAF50) : Colors.grey[300],
      ),
    );
  }
}
