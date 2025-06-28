import 'package:flutter/material.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/functions_uses.dart';

// Reusable Medicine Order Card Widget
class MedicineOrderCard extends StatelessWidget {
  final String medicineName;
  final String condition;
  final String dosage;
  final VoidCallback onTapToOrder;

  const MedicineOrderCard({
    super.key,
    required this.medicineName,
    required this.condition,
    required this.dosage,
    required this.onTapToOrder,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return GestureDetector(
      onTap: onTapToOrder,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: height * 0.08,
          maxHeight: height * 0.12,
        ),
        margin: EdgeInsets.only(bottom: height * 0.015),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBBF7D0),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(width * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.1,
              height: width * 0.1,
              constraints: BoxConstraints(
                minWidth: 35,
                maxWidth: 50,
                minHeight: 35,
                maxHeight: 50,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              child: Image.asset(
                'assets/images/bluepilllogo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    medicineName,
                    style: style_(
                      fontSize: (width * 0.035).clamp(14.0, 18.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.003),
                  Text(
                    '$condition · $dosage',
                    style: style_(
                      fontSize: (width * 0.028).clamp(12.0, 15.0),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF474747),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.025,
                vertical: height * 0.008,
              ),
              child: Text(
                'Tap to order',
                style: style_(
                  fontSize: (width * 0.032).clamp(12.0, 16.0),
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RefillPage extends StatefulWidget {
  const RefillPage({super.key});

  @override
  State<RefillPage> createState() => _RefillPageState();
}

class _RefillPageState extends State<RefillPage> {
  bool showSuccessNotification = false;
  int selectedQuantity = 1;
  int orderedQuantity = 0;
  String orderedMedicineName = '';
  List<Map<String, dynamic>> medicines = [];
  bool isLoading = true;

  // WhatsApp phone number (with country code) - Update this with your actual number
  final String whatsappNumber = '919238262562';

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final patientDatabase = PatientDatabase();
      final allMedicines = await patientDatabase.getAllMedicines();

      setState(() {
        medicines = allMedicines
            .map((medicine) => {
                  'name': '${medicine['name']} ',
                  'condition': medicine['disease'],
                  'dosage': _getDosageText(medicine['timing']),
                  'originalData': medicine, // Store original data for dialog
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading medicines: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getDosageText(Map<String, dynamic> timing) {
    List<String> times = [];
    if (timing['morning'] == true) times.add('Morning');
    if (timing['afternoon'] == true) times.add('Afternoon');
    if (timing['evening'] == true) times.add('Evening');

    String timeText = times.join(', ');
    String mealText = '';

    if (timing['beforeMeal'] == true && timing['afterMeal'] == true) {
      mealText = 'Before & After Meal';
    } else if (timing['beforeMeal'] == true) {
      mealText = 'Before Meal';
    } else if (timing['afterMeal'] == true) {
      mealText = 'After Meal';
    }

    return '$timeText${mealText.isNotEmpty ? ' - $mealText' : ''}';
  }

  Future<void> _sendWhatsAppMessage(String medicineName, int quantity) async {
    try {
      String message = '''Hello! I would like to order a medicine refill:

📋 Medicine: $medicineName
📦 Quantity: $quantity pack(s)
🏥 Type: Prescription Refill

Please confirm the availability and delivery details.

Thank you!''';

      String encodedMessage = Uri.encodeComponent(message);
      String whatsappUrl =
          'whatsapp://send?phone=$whatsappNumber&text=$encodedMessage';

      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Open Play Store as fallback
        final fallbackUri = Uri.parse(
            "https://play.google.com/store/apps/details?id=com.whatsapp");
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQuantityDialog(String medicineName) {
    // Find the medicine data for this medicine name
    final medicineData = medicines.firstWhere(
      (med) => med['name'] == medicineName,
      orElse: () => {},
    );

    // Extract the required information
    final String displayName = medicineData['name'] ?? medicineName;
    final String disease = medicineData['condition'] ?? '';
    final String timing = medicineData['dosage'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: width * 0.9,
                  maxHeight: height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.03,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top green icon in light background
                        Container(
                          padding: EdgeInsets.all(width * 0.04),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE9FBF1), // soft green background
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: const Color(0xFF00C853), // bright green icon
                            size: (width * 0.09).clamp(30.0, 40.0),
                          ),
                        ),

                        SizedBox(height: height * 0.025),

                        // Fixed alignment for "Q" image and "uick Access" text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/q.png",
                              width: (width * 0.038).clamp(15.0, 20.0),
                              height: (width * 0.038).clamp(15.0, 20.0),
                              fit: BoxFit.contain,
                            ),
                            Text(
                              "uick Access",
                              style: style_(
                                fontSize: (width * 0.05).clamp(18.0, 24.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.02),

                        // Medicine Info Box - Updated with dynamic data
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(width * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF20C65D), width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: (width * 0.04).clamp(14.0, 18.0),
                                  color: const Color(0xFF1B1B1F),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: height * 0.005),
                              Text(
                                disease,
                                style: TextStyle(
                                  fontSize: (width * 0.035).clamp(12.0, 16.0),
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                timing,
                                style: TextStyle(
                                  fontSize: (width * 0.035).clamp(12.0, 16.0),
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.025),

                        // Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Minus Button
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (selectedQuantity > 1) {
                                  setDialogState(() {
                                    selectedQuantity--;
                                  });
                                }
                              },
                              color: Colors.grey,
                              iconSize: (width * 0.07).clamp(24.0, 32.0),
                              constraints: BoxConstraints(
                                minWidth: width * 0.1,
                                minHeight: width * 0.1,
                              ),
                            ),

                            // Quantity Box
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.01,
                              ),
                              constraints: BoxConstraints(
                                minWidth: width * 0.15,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFBBF7D0), width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0FFF4),
                              ),
                              child: Text(
                                '$selectedQuantity',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (width * 0.05).clamp(18.0, 24.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B1B1F),
                                ),
                              ),
                            ),

                            // Plus Button
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setDialogState(() {
                                  selectedQuantity++;
                                });
                              },
                              color: Colors.white,
                              iconSize: (width * 0.07).clamp(24.0, 32.0),
                              constraints: BoxConstraints(
                                minWidth: width * 0.1,
                                minHeight: width * 0.1,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.015),

                        // Info Text
                        Text(
                          'Requesting $selectedQuantity pack(s) of $displayName',
                          style: TextStyle(
                            fontSize: (width * 0.035).clamp(12.0, 16.0),
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: height * 0.03),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    selectedQuantity = 1;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.018),
                                  backgroundColor: const Color(0xFFF0F1F4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: (width * 0.04).clamp(14.0, 18.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.of(context).pop();

                                  setState(() {
                                    orderedQuantity = selectedQuantity;
                                    orderedMedicineName = displayName;
                                    showSuccessNotification = true;
                                  });

                                  await _sendWhatsAppMessage(
                                      displayName, selectedQuantity);

                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    if (mounted) {
                                      setState(() {
                                        showSuccessNotification = false;
                                      });
                                    }
                                  });

                                  setState(() {
                                    selectedQuantity = 1;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.018),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: (width * 0.045).clamp(16.0, 22.0),
                                ),
                                label: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: (width * 0.04).clamp(14.0, 18.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FFEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22C55E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medicine Refills',
              style: style_(
                color: Colors.white,
                fontSize: (width * 0.045).clamp(16.0, 20.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Request prescription refills',
              style: style_(
                color: Colors.white,
                fontSize: (width * 0.03).clamp(12.0, 16.0),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_box_outlined,
                      color: const Color(0xFF4ACA00),
                      size: (width * 0.06).clamp(20.0, 28.0),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: Text(
                        'All Prescribed Medicines',
                        style: style_(
                          fontSize: (width * 0.04).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      )
                    : medicines.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.08),
                              child: Text(
                                'No medicines found.\nPlease add medicines in your profile.',
                                textAlign: TextAlign.center,
                                style: style_(
                                  fontSize: (width * 0.04).clamp(14.0, 18.0),
                                  color: Colors.grey[600]!,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.04),
                            itemCount: medicines.length,
                            itemBuilder: (context, index) {
                              return MedicineOrderCard(
                                medicineName: medicines[index]['name']!,
                                condition: medicines[index]['condition']!,
                                dosage: medicines[index]['dosage']!,
                                onTapToOrder: () {
                                  _showQuantityDialog(
                                      medicines[index]['name']!);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
          if (showSuccessNotification)
            Positioned(
              top: height * 0.025,
              left: width * 0.04,
              right: width * 0.04,
              child: Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF17C300),
                  borderRadius: BorderRadius.circular(width * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.015),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: const Color(0xFF45B925),
                        size: (width * 0.06).clamp(20.0, 28.0),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Placed Successfully!',
                            style: style_(
                              color: Colors.white,
                              fontSize: (width * 0.04).clamp(14.0, 18.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            '$orderedMedicineName · $orderedQuantity pack(s) ordered',
                            style: style_(
                              color: Colors.white,
                              fontSize: (width * 0.03).clamp(12.0, 16.0),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
