import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/widgets/common/loading_screen.dart';
import 'package:sanjeevika/view/screens/profile/yajurnew_information_form.dart';
import '../../../viewmodels/data_controller.dart';

class getstartedscreen extends StatefulWidget {
  const getstartedscreen({super.key});

  @override
  State<getstartedscreen> createState() => _getstartedscreenState();
}

class _getstartedscreenState extends State<getstartedscreen> {
  // Removed: final data = Get.find<Datacontroller>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width; // ✅ safer screen width

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size / 3),
                  Image.asset(
                    'assets/images/sanjeevikalogo.png',
                    width: size / 4,
                  ),
                  SizedBox(height: size / 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '“Welcome to ',
                        style: TextStyle(
                          color: const Color(0xFF005014),
                          fontWeight: FontWeight.w500,
                          fontSize: size / 15,
                        ),
                      ),
                      Text(
                        'Sanjeevika”',
                        style: TextStyle(
                          color: const Color(0xFF005014),
                          fontWeight: FontWeight.w900,
                          fontSize: size / 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size / 15),
                  Text(
                    'Your Personal Health Companion',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: size / 30,
                    ),
                  ),
                  SizedBox(height: size / 3),
                  Text(
                    textAlign: TextAlign.center,
                    '"Start by entering the User details\n to begin your care journey."',
                    style: TextStyle(
                      color: const Color(0xFF005014),
                      fontWeight: FontWeight.w500,
                      fontSize: size / 20,
                    ),
                  ),
                  SizedBox(height: size / 2),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff22C55E),
                    ),
                    onPressed: () {
                      Get.find<Datacontroller>().getstartedclicked();
                      navigateWithLoading();
                    },
                    child: const Text(
                      'Let\'s Get started ->',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void navigateWithLoading() async {
  Get.dialog(
    loading_screen(),
    barrierDismissible: false,
  );

  await Future.delayed(const Duration(seconds: 3));

  Get.back();

  Get.to(
    () => InformationForm(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 350),
  );
}
