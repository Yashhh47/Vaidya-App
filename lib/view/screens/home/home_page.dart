import 'package:flutter/material.dart';
import 'package:sanjeevika/view/screens/profile/yajurnew_myprofile.dart';
import 'home_page2.dart';
import 'home_page3.dart' hide SizeConfig, style_;
import 'package:sanjeevika/view/widgets/common/side_bar.dart';
import '../../../viewmodels/data_controller.dart';
import '../../../utils/functions_uses.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import 'package:sanjeevika/services/medicine_status_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Datacontroller data;
  List<Map<String, dynamic>> todaysMedications = [];
  List<Map<String, dynamic>> missedMedicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    data = Get.find<Datacontroller>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final patientDatabase = PatientDatabase();

      // Load today's medications
      final medications = await patientDatabase.getTodaysMedications();

      // Load missed medicines
      final missed = await MedicineStatusService.getMissedMedicines();

      setState(() {
        todaysMedications = medications;
        missedMedicines = missed;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading home page data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _dismissMissedMedicine(int index) async {
    await MedicineStatusService.removeMissedMedicine(index);
    setState(() {
      missedMedicines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FFEE),
        appBar: _buildAppBar(width, height),
        drawer: const CustomSideBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffD7F3B8), Color(0xffffffff)],
              begin: Alignment.topCenter,
              end: Alignment.center,
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show missed medicine notifications first
                if (missedMedicines.isNotEmpty)
                  ...missedMedicines.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> medicine = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: height * 0.01),
                      child: _buildMissedMedicineCard(
                          width, height, medicine, index),
                    );
                  }).toList(),

                // Your original components - keeping them exactly as they were
                TodaysMedicationsSection(),
                SizedBox(height: height * 0.03),
                QuickAccessSection(),
                SizedBox(height: width * 0.4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissedMedicineCard(
      double width, double height, Map<String, dynamic> medicine, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.067),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: width * 0.035,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.067),
          gradient: LinearGradient(
            colors: [
              Color(0xffFFCBCB),
              Color(0xffFFE6D1),
              Color(0xffFFDDC0),
              Color(0xffFFDCDC),
              Color(0xffFFCBCB),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Color(0xffA00000),
                      size: width * 0.063,
                    ),
                    SizedBox(width: width * 0.004),
                    Text(
                      "Missed Medicine:",
                      style: style_(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _dismissMissedMedicine(index),
                  child: Icon(
                    Icons.close,
                    color: Color(0xff820707),
                    size: width * 0.063,
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.03),
            Text(
              "You missed your ${medicine['time'].toLowerCase()} ${medicine['timing'].toLowerCase()} medicine: ${medicine['medicine']}.\nPlease take care next time.\n -your health matters 💚.",
              textAlign: TextAlign.left,
              style: style_(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double width, double height) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: const Color(0xFFD7F3B8),
      elevation: 0,
      titleSpacing: -10,
      title: Row(
        children: [
          _buildAppBarLogo(width, height),
          SizedBox(width: width * 0.01),
          Text(
            'Sanjeevika',
            style: style_(
              color: Color(0xFF005014),
              fontWeight: FontWeight.w900,
              fontSize: width * 0.06,
            ),
          ),
        ],
      ),
      actions: [
        _buildUserProfile(width, height),
        SizedBox(width: width * 0.01),
      ],
    );
  }

  Widget _buildAppBarLogo(double width, double height) {
    return Image.asset(
      'assets/images/sanjeevikalogo.png',
      height: width * 0.13,
      width: width * 0.14,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: width * 0.12,
          width: width * 0.12,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_hospital,
            color: Colors.green,
            size: width * 0.04,
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(double width, double height) {
    return GestureDetector(
      onTap: () {
        Get.to(MyProfilePage(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 300));
      },
      child: Container(
        height: width * 0.11, // Reduced from 0.12 to 0.08 (8% of screen width)
        padding: EdgeInsets.fromLTRB(
            width * 0.01, // Reduced from 0.015 to 0.01 (1% of screen width)
            0,
            width * 0.02, // Reduced from 0.03 to 0.02 (2% of screen width)
            0),
        margin: EdgeInsets.only(
            right: width *
                0.01), // Reduced from 0.015 to 0.01 (1% of screen width)
        decoration: BoxDecoration(
          color: const Color(0xFFE8FAE7),
          border: Border.all(color: const Color(0xFF97DF4B), width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: width *
                  0.03, // Reduced from 0.04 to 0.025 (2.5% of screen width)
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0XFF005014),
                size: width *
                    0.03, // Reduced from 0.035 to 0.025 (2.5% of screen width)
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: width *
                      0.015), // Reduced from 0.018 to 0.012 (1.2% of screen width)
              child: Obx(() => Text(
                    data.patient_ID.value.isNotEmpty
                        ? data.patient_ID.value
                        : 'SJVK-LOADING',
                    style: style_(
                      color: Color(0xFF005014),
                      fontWeight: FontWeight.w900,
                      fontSize: width *
                          0.035, // Reduced from 0.045 to 0.032 (3.2% of screen width)
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(double width, double height) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.067),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: width * 0.035,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.067),
          gradient: LinearGradient(
            colors: [
              Color(0xffFFCBCB),
              Color(0xffFFE6D1),
              Color(0xffFFDDC0),
              Color(0xffFFDCDC),
              Color(0xffFFCBCB),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationHeader(width, height),
            SizedBox(height: width * 0.03),
            _buildNotificationMessage(width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_none,
              color: Color(0xffA00000),
              size: width * 0.063,
            ),
            SizedBox(width: width * 0.004),
            Text(
              "Gentle Reminder:",
              style: style_(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: width * 0.04,
              ),
            ),
          ],
        ),
        Icon(
          Icons.close,
          color: Color(0xff820707),
          size: width * 0.063,
        ),
      ],
    );
  }

  Widget _buildNotificationMessage(double width, double height) {
    return Text(
      "We noticed you missed your morning before-meal medicine. Please take care next time.\n -your health matters 💚.",
      textAlign: TextAlign.left,
      style: style_(
        fontSize: width * 0.04,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  void _dismissNotification() {
    print('Notification dismissed');
  }
}
