import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/screens/onboarding/start_screen1.dart';
import 'package:sanjeevika/view/screens/home/home_page.dart';
import 'package:sanjeevika/services/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Show splash screen for 2 seconds
    await Future.delayed(Duration(seconds: 3));

    // Check if user is already logged in
    bool isLoggedIn = await UserSession.isUserLoggedIn();

    if (isLoggedIn) {
      // User is already logged in, go to home page
      Get.offAll(() => HomePage(),
          transition: Transition.zoom, duration: Duration(milliseconds: 300));
    } else {
      // User needs to login, go to start screen (your existing flow)
      Get.offAll(() => StartScreen1(),
          transition: Transition.zoom, duration: Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenWidget();
  }
}

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.95;
    return Scaffold(
      backgroundColor: Color(0xFFC2E96A),
      body: Center(
        child: Image.asset('assets/images/sanjeevikalogo.png', width: size / 4),
      ),
    );
  }
}
