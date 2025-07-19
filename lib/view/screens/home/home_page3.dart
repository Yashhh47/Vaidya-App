import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import '../../../viewmodels/data_controller.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width * 0.95;
    screenHeight = _mediaQueryData.size.height * 0.95;
  }
}

TextStyle style_({
  String fontFamily = 'Montserrat',
  FontWeight fontWeight = FontWeight.w900,
  double fontSize = 16.0,
  Color color = Colors.black,
}) {
  return TextStyle(
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: color,
  );
}

class TodaysMedicationsSection extends StatefulWidget {
  const TodaysMedicationsSection({super.key});

  @override
  _TodaysMedicationsSectionState createState() =>
      _TodaysMedicationsSectionState();
}

class _TodaysMedicationsSectionState extends State<TodaysMedicationsSection> {
  late Datacontroller data;
  List<Map<String, dynamic>> medications = [];
  bool isLoading = true;

  void _handleMedicationAction(Map<String, dynamic> medication) {
    if (medication['status'] == 'pending') {
      setState(() {
        medication['status'] = 'taken';
        medication['takenTime'] =
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}';
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medicine marked as taken!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<Color> green_color = [
    Color(0xffC6FFAA),
    Color(0xffDBFFC3),
    Color(0xffF1FFDC),
    Color(0xffEDFFC2),
    Color(0xffDFFFCF),
    Color(0xffD3FFC5),
    Color(0xffC9FF8F),
  ];

  List<Color> blue_color = [
    Color(0xffB4FFF5),
    Color(0xffA8FFCE),
    Color(0xffCCFEFF),
    Color(0xffB1FFD9),
    Color(0xffC0F8EF),
    Color(0xffC7FFF0),
    Color(0xffBEFFE4),
  ];

  List<Color> red_color = [
    Color(0xffFFC8C8),
    Color(0xffFFD7C7),
    Color(0xffFFCECE),
    Color(0xffFFDAC9),
    Color(0xffFFD7CC),
    Color(0xffFFE5DA),
    Color(0xffFFE6E6),
    Color(0xffFFB8B8),
  ];

  @override
  void initState() {
    super.initState();
    data = Get.find<Datacontroller>();
    _loadTodaysMedications();
  }

  Future<void> _loadTodaysMedications() async {
    try {
      final patientDatabase = PatientDatabase();
      final todaysMeds = await patientDatabase.getTodaysMedications();

      setState(() {
        medications = todaysMeds;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading today\'s medications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * 0.04),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.green,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.015),
              child: Text(
                "Today's Medications",
                style: style_(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.025),
        if (isLoading)
          Container(
            height: width * 0.4,
            margin: EdgeInsets.symmetric(horizontal: width * 0.02),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          )
        else if (medications.isEmpty)
          Container(
            height: width * 0.4,
            margin: EdgeInsets.symmetric(horizontal: width * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: green_color),
              borderRadius: BorderRadius.circular(width * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No medications scheduled for today.\nAdd medicines in your profile.',
                textAlign: TextAlign.center,
                style: style_(
                  fontSize: width * 0.035,
                  color: Colors.grey[700]!,
                ),
              ),
            ),
          )
        else
          _buildStackedCards(),
      ],
    );
  }

  Widget _buildStackedCards() {
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return GestureDetector(
      onTap: () => _showMedicationBottomSheet(),
      child: Container(
        height: width * 0.45,
        margin: EdgeInsets.symmetric(horizontal: width * 0.01),
        child: Stack(
          children: [
            if (medications.length > 2)
              Positioned(
                top: width * 0.070,
                left: width * 0.025,
                child: _buildMedicationCard(
                  medications[2]['time'] ?? 'Evening',
                  medications[2]['timing'] ?? 'After Meal',
                  medications[2]['medicine'] ?? 'No Medicine',
                  medications[2]['disease'] ?? 'General',
                  medications[2]['status'] ?? 'pending',
                  medications[2]['takenTime'] ?? '',
                  width * 0.82,
                  0.6,
                  medications[2]['status'] == 'taken'
                      ? green_color
                      : medications[2]['status'] == 'pending'
                          ? blue_color
                          : red_color,
                ),
              ),
            if (medications.length > 1)
              Positioned(
                top: width * 0.035,
                left: width * 0.015,
                child: _buildMedicationCard(
                  medications[1]['time'] ?? 'Afternoon',
                  medications[1]['timing'] ?? 'Before Meal',
                  medications[1]['medicine'] ?? 'No Medicine',
                  medications[1]['disease'] ?? 'General',
                  medications[1]['status'] ?? 'pending',
                  medications[1]['takenTime'] ?? '',
                  width * 0.85,
                  0.8,
                  medications[1]['status'] == 'taken'
                      ? green_color
                      : medications[1]['status'] == 'pending'
                          ? blue_color
                          : red_color,
                ),
              ),
            if (medications.isNotEmpty)
              Positioned(
                top: 0,
                left: 0,
                child: _buildMedicationCard(
                  medications[0]['time'] ?? 'Morning',
                  medications[0]['timing'] ?? 'After Meal',
                  medications[0]['medicine'] ?? 'No Medicine',
                  medications[0]['disease'] ?? 'General',
                  medications[0]['status'] ?? 'pending',
                  medications[0]['takenTime'] ?? '',
                  width * 0.88,
                  1.0,
                  medications[0]['status'] == 'taken'
                      ? green_color
                      : medications[0]['status'] == 'pending'
                          ? blue_color
                          : red_color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(
    String time,
    String timing,
    String medicine,
    String disease,
    String status,
    String takenTime,
    double cardWidth,
    double opacity,
    List<Color> colors,
  ) {
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: width * 0.35,
        width: width / 1.09,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(width / 15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (medications[0]['status'] == 'pending')
                        Image.asset(
                          "assets/images/bluepilllogo.png",
                          width: width * 0.12,
                        ),
                      if (medications[0]['status'] == 'taken')
                        Image.asset(
                          "assets/images/greenpilllogo.png",
                          width: width * 0.12,
                        ),
                      if (medications[0]['status'] == 'missed')
                        Image.asset(
                          "assets/images/redpilllogo.png",
                          width: width * 0.12,
                        ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              time,
                              style: style_(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timing,
                              style: style_(
                                fontSize: width * 0.040,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Text(
                    medicine,
                    style: style_(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff08009C),
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    disease,
                    style: style_(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff004B79),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: width * 0.35,
              height: width * 0.25,
              decoration: BoxDecoration(
                color: status == 'taken'
                    ? Color(0xffF2FFEC)
                    : status == 'missed'
                        ? Color(0xffFFF6F6)
                        : Color(0xffEAFDFF),
                borderRadius: BorderRadius.circular(width * 0.05),
                border: Border.all(
                    color: status == 'taken'
                        ? Color(0xff73DD69)
                        : status == 'missed'
                            ? Color(0xffFF7676)
                            : Color(0xff5BE3C3),
                    width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    status == 'taken' ? 'TAKEN' : 'PENDING',
                    style: style_(
                      fontSize: width * 0.055,
                      fontWeight: FontWeight.bold,
                      color: status == 'taken'
                          ? Color(0xff205100)
                          : Color(0xff00929A),
                    ),
                  ),
                  if (takenTime.isNotEmpty)
                    Text(
                      takenTime,
                      style: style_(
                        fontSize: width * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMedicationBottomSheet(),
    );
  }

  Widget _buildMedicationBottomSheet() {
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Container(
      height: height * 0.7,
      decoration: BoxDecoration(
        color: Color(0xffF6FFF1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width * 0.08),
          topRight: Radius.circular(width * 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: height * 0.02),
            width: width * 0.12,
            height: height * 0.005,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: height * 0.03),
          Text(
            "Today's Medicine Log",
            style: style_(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.03),
          Expanded(
            child: medications.isEmpty
                ? Center(
                    child: Text(
                      'No medications scheduled for today.',
                      style: style_(
                        fontSize: width * 0.04,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    itemCount: medications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == medications.length) {
                        return SizedBox(height: height * 0.1);
                      }
                      return _buildBottomSheetMedicationCard(
                          medications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetMedicationCard(Map<String, dynamic> medication) {
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;
    {
      double width = SizeConfig.screenWidth;
      double height = SizeConfig.screenHeight;

      Color cardColor;
      Color statusColor;
      String statusText;
      String buttonText;
      Color buttontextcolor;
      Color borderColor;
      Color buttonfillcolor;
      List<Color> colors;

      switch (medication['status']) {
        case 'taken':
          colors = green_color;
          statusText = 'TAKEN';
          buttonText = 'TAKEN';
          buttontextcolor = Color(0xff205100);
          borderColor = Color(0xff73DD69);
          buttonfillcolor = Color(0xffF2FFEC);
          break;
        case 'pending':
          colors = blue_color;
          statusText = 'TAP TO';
          buttonText = 'TAKE NOW';
          buttontextcolor = Color(0xff00929A);
          borderColor = Color(0xff5BE3C3);
          buttonfillcolor = Color(0xffEAFDFF);
          break;
        case 'missed':
          colors = red_color;
          statusText = 'MISSED';
          buttonText = 'MISSED';
          buttontextcolor = Color(0xffFF0004);
          borderColor = Color(0xffFF7676);
          buttonfillcolor = Color(0xffFFF6F6);
          break;
        default:
          colors = [Colors.grey.shade200, Colors.grey.shade300];
          statusText = 'UNKNOWN';
          buttonText = 'UNKNOWN';
          buttontextcolor = Colors.grey;
          borderColor = Colors.grey;
          buttonfillcolor = Colors.grey.shade50;
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: height * 0.008),
        height: width * 0.35,
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(width * 0.055),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (medication['status'] == "taken")
                        Image.asset(
                          "assets/images/greenpilllogo.png",
                          width: width * 0.12,
                        ),
                      if (medication['status'] == "pending")
                        Image.asset(
                          "assets/images/bluepilllogo.png",
                          width: width * 0.12,
                        ),
                      if (medication['status'] == "missed")
                        Image.asset(
                          "assets/images/redpilllogo.png",
                          width: width * 0.12,
                        ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${medication['time']}',
                              style: style_(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${medication['timing']}',
                              style: style_(
                                fontSize: width * 0.040,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Text(
                    '${medication['medicine']}',
                    style: style_(
                      fontSize: width * 0.037,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff08009C),
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '${medication['disease']}',
                    style: style_(
                      fontSize: width * 0.037,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff004B79),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _handleMedicationAction(medication),
              child: Container(
                width: width * 0.37,
                height: width * 0.27,
                decoration: BoxDecoration(
                  color: buttonfillcolor,
                  borderRadius: BorderRadius.circular(width * 0.06),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (medication['status'] == 'pending')
                      Text(
                        statusText,
                        style: style_(
                          fontSize: width * 0.030,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    Text(
                      buttonText,
                      style: style_(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: buttontextcolor,
                      ),
                    ),
                    if (medication['status'] == 'taken' &&
                        medication['takenTime'].isNotEmpty)
                      Text(
                        medication['takenTime'],
                        style: style_(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (medication['status'] == 'missed' &&
                        medication['takenTime'].isNotEmpty)
                      Text(
                        medication['takenTime'],
                        style: style_(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
