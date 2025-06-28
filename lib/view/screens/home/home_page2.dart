import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';
import 'package:sanjeevika/view/screens/appointments/appointment_page.dart';
import 'package:sanjeevika/view/screens/medicine/refill_page.dart';
import 'package:sanjeevika/view/screens/chat/ai_chat_screen.dart';
import 'package:sanjeevika/view/screens/emergency/emergency.dart';
import 'package:sanjeevika/utils/functions_uses.dart';
import 'package:get/get.dart';

class QuickAccessSection extends StatefulWidget {
  const QuickAccessSection({Key? key}) : super(key: key);

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  late Datacontroller data;

  @override
  void initState() {
    super.initState();
    data = Get.find<Datacontroller>();
  }

  @override
  Widget build(BuildContext context) {
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with green accent line
        _buildSectionTitle(width, height),
        SizedBox(height: width * 0.05),

        // First row: Appointments and Refills
        _buildFirstRow(context, width, height),
        SizedBox(height: width * 0.033),

        // Second row: AI Assistant and Emergency
        _buildSecondRow(context, width, height),
      ],
    );
  }

  Widget _buildSectionTitle(double width, double height) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.green,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 6),
        child: Row(
          children: [
            Image(
              image: AssetImage("images/q.png"),
              width: width * 0.038,
            ),
            Text(
              "uick Access",
              style: style_(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstRow(BuildContext context, double width, double height) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessCard(
            context: context,
            width: width,
            height: height,
            backgroundColor: Colors.blue.shade600,
            icon: Icons.calendar_today_outlined,
            iconColor: Color(0xff00428D),
            title: "APPOINTMENTS",
            subtitle: "4 Active",
            onTap: () => _navigateToPage(context, const AppointmentPage()),
            fontcolor: Color(0xff00428D),
          ),
        ),
        SizedBox(width: width * 0.029),
        Expanded(
          child: _buildQuickAccessCard(
            context: context,
            width: width,
            height: height,
            backgroundColor: Colors.green,
            icon: Icons.medical_information_outlined,
            iconColor: Color(0xff065C00),
            title: "REFILLS",
            subtitle: "2 Due Soon",
            onTap: () => _navigateToPage(context, const RefillPage()),
            fontcolor: Color(0xff065C00),
            colors: [
              Color(0xff00DCE0),
              Color(0xff1AFF7D),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondRow(BuildContext context, double width, double height) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessCard(
            context: context,
            width: width,
            height: height,
            backgroundColor: Colors.pink,
            icon: Icons.chat_bubble_outline,
            iconColor: Color(0xff650083),
            title: "AI ASSISTANT",
            subtitle: "Ask Anything",
            onTap: () => _navigateToPage(context, const AiPage()),
            fontcolor: Color(0xff650083),
            colors: [
              Color(0xffCB94FF),
              Color(0xffFF8EE3),
              Color(0xffF8A9FF),
            ],
          ),
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: _buildQuickAccessCard(
            context: context,
            width: width,
            height: height,
            backgroundColor: Colors.red,
            icon: Icons.warning_amber_outlined,
            iconColor: Color(0xff570000),
            title: "EMERGENCY",
            subtitle: "SOS Help",
            onTap: () => _navigateToPage(context, const EmergencyPage()),
            fontcolor: Color(0xff570000),
            colors: [
              Color(0xffFFB17C),
              Color(0xffFFA389),
              Color(0xffFF7C7C),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required double width,
    required double height,
    required Color backgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color fontcolor = Colors.black,
    Color? iconColor,
    List<Color> colors = const [
      Color(0xff45ECFF),
      Color(0xff39B5FF),
      Color(0xff008FE4),
    ],
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.067),
        ),
        elevation: 5,
        child: Container(
          height: width * 0.36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(width * 0.067),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Colors.white,
                  size: width * 0.08,
                ),
                SizedBox(height: width * 0.05),
                Text(
                  title,
                  style: style_(
                    color: fontcolor,
                    fontWeight: FontWeight.w900,
                    fontSize: width * 0.043,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: width * 0.015),
                Text(
                  subtitle,
                  style: style_(
                    fontSize: width * 0.04,
                    color: fontcolor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
