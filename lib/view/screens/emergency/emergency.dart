import 'package:flutter/material.dart';
import 'package:sanjeevika/utils/functions_uses.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<Map<String, dynamic>> emergencyContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final patientDatabase = PatientDatabase();
      final contacts = await patientDatabase.getEmergencyContacts();

      setState(() {
        emergencyContacts = contacts
            .map((contact) => {
          'name': contact['name'] ?? 'Unknown',
          'mobile':
          contact['phone']?.replaceAll('+91 ', '') ?? '0000000000',
          'designation': 'Emergency Contact'
        })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading emergency contacts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: -10,
        title: Row(
          children: [
            SizedBox(width: width * 0.01),
            Icon(Icons.warning_amber_outlined,
                color: Colors.white, size: width * 0.06),
            SizedBox(width: width * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency SOS',
                    style: style_(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.045)),
                Text('Tap to call for help',
                    style: style_(
                        color: Colors.white,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: Colors.red[600], size: width * 0.06),
                SizedBox(width: width * 0.02),
                Image(
                  image: AssetImage("assets/images/q.png"),
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
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyServiceButton(
                    context,
                    title: 'HOSPITAL',
                    subtitle: "Hospital Emergency",
                    number: '108',
                    color: const Color(0xFFFF4444),
                    showIcon: true,
                    onTap: () => _showCallDialog(context,
                        'City Hospital Emergency', '108', width, height),
                    width: width,
                    height: height,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _buildEmergencyServiceButton(
                    context,
                    title: 'POLICE',
                    subtitle: 'Police Emergency',
                    number: '100',
                    color: const Color(0xFFFF4444),
                    showIcon: false,
                    onTap: () => _showCallDialog(
                        context, 'Police Emergency', '100', width, height),
                    width: width,
                    height: height,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    color: Colors.blue, size: width * 0.06),
                SizedBox(width: width * 0.02),
                Text('All Emergency Contacts',
                    style: style_(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
            SizedBox(height: height * 0.02),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
            else if (emergencyContacts.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.08),
                  child: Text(
                    'No emergency contacts found.\nPlease add contacts in your profile.',
                    textAlign: TextAlign.center,
                    style: style_(
                      fontSize: width * 0.04,
                      color: Colors.grey[600]!,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  final contact = emergencyContacts[index];
                  return _buildContactCard(
                    context,
                    name: contact['name']!,
                    role: contact['designation']!,
                    phone: '+91 ${contact['mobile']!}',
                    onTap: () => _showCallDialog(context, contact['name']!,
                        '+91 ${contact['mobile']!}', width, height),
                    width: width,
                    height: height,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceButton(BuildContext context,
      {required String title,
        String? subtitle,
        required String number,
        required Color color,
        required VoidCallback onTap,
        bool showIcon = false,
        required double width,
        required double height}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.09,
        padding: EdgeInsets.all(width * 0.02),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width * 0.025),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: style_(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.04),
                textAlign: TextAlign.center,
                maxLines: 2),
            if (subtitle != null)
              Text(subtitle,
                  style: style_(color: Colors.white, fontSize: width * 0.03),
                  textAlign: TextAlign.center),
            SizedBox(height: height * 0.003),
            Text(number,
                style: style_(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.028)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context,
      {required String name,
        required String role,
        required String phone,
        required VoidCallback onTap,
        required double width,
        required double height}) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.1,
            height: width * 0.1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.05),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 3),
                    blurRadius: 5)
              ],
            ),
            child: Icon(Icons.person_outline_outlined,
                color: const Color(0xFFE53935), size: width * 0.075),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: style_(
                        fontSize: width * 0.035, fontWeight: FontWeight.bold)),
                Text(role,
                    style: style_(
                        fontSize: width * 0.028, color: Colors.grey[600]!)),
                Text(phone,
                    style: style_(
                        fontSize: width * 0.028, color: Colors.grey[700]!)),
              ],
            ),
          ),
          Row(
            children: [
              Text('Tap to call',
                  style: style_(
                      fontSize: width * 0.025, color: Colors.grey[600]!)),
              SizedBox(width: width * 0.06),
              GestureDetector(
                onTap: onTap,
                child: Icon(Icons.phone_outlined,
                    color: Colors.red, size: width * 0.075),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String name, String number,
      double width, double height) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.05)),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.045, vertical: height * 0.025),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined,
                    color: const Color(0xFFE53935), size: width * 0.125),
                SizedBox(height: height * 0.025),
                Text('Confirm Emergency Call',
                    style: style_(
                        fontWeight: FontWeight.bold, fontSize: width * 0.045)),
                SizedBox(height: height * 0.01),
                Text('Are you sure you want to call?',
                    style:
                    style_(fontSize: width * 0.038, color: Colors.black54)),
                SizedBox(height: height * 0.02),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: height * 0.015),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.02),
                      color: Colors.white),
                  child: Text(name,
                      textAlign: TextAlign.center,
                      style: style_(
                          fontWeight: FontWeight.bold, fontSize: width * 0.04)),
                ),
                SizedBox(height: height * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel',
                            style: style_(fontSize: width * 0.035)),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4D4D)),
                        onPressed: () {
                          Navigator.pop(context);
                          makePhoneCall(number);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_outlined,
                                color: Colors.white, size: width * 0.04),
                            SizedBox(width: width * 0.01),
                            Text('Call Now',
                                style: style_(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.03)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}