import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/screens/profile/yajurnew_information_form.dart';
import '../../../viewmodels/data_controller.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class loading_screen extends StatefulWidget {
  const loading_screen({super.key});

  @override
  State<loading_screen> createState() => _loading_screenState();
}

class _loading_screenState extends State<loading_screen> {
  late Datacontroller data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = Get.find<Datacontroller>();
  }
  @override
  Widget build(BuildContext context) {
    double size = data.size;
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/sanjeevikalogo.png",
                  width: 75,
                ),
                SizedBox(
                  height: size / 15,
                ),
                Text(
                  textAlign: TextAlign.left,
                  '"Bringing wellness\n to your fingertips..."',
                  style: TextStyle(
                    color: Color(0xFF005014),
                    fontWeight: FontWeight.w600,
                    fontSize: size / 18,
                  ),
                ),
                SizedBox(
                  height: size / 3,
                ),
                Center(
                    child: Lottie.asset("assets/animations/loading_lottie.json",
                        width: size / 3))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
