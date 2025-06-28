import 'package:flutter/material.dart';
import 'package:sanjeevika/services/patient_crud.dart';
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

    return Container(
      width: double.infinity,
      height: height * 0.1,
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.04),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
            child: Image.asset(
              'images/bluepilllogo.png',
              width: width * 0.1,
              height: width * 0.1,
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
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: height * 0.003),
                Text(
                  '$condition · $dosage',
                  style: style_(
                    fontSize: width * 0.028,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF474747),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.02),
          GestureDetector(
            onTap: onTapToOrder,
            child: Text(
              'Tap to order',
              style: style_(
                fontSize: width * 0.035,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  'name': '${medicine['name']} ${medicine['quantity']}',
                  'condition': medicine['disease'],
                  'dosage': _getDosageText(medicine['timing']),
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

  void _showQuantityDialog(String medicineName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double width = SizeConfig.screenWidth;
            double height = SizeConfig.screenHeight;

            return Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.08),
                padding: EdgeInsets.all(width * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.04),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: const Color(0xFF4CAF50),
                        size: width * 0.08,
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Text(
                      'Select Quantity',
                      style: style_(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(width * 0.03),
                      margin: EdgeInsets.symmetric(vertical: height * 0.01),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFBBF7D0),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(width * 0.03),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicineName,
                            style: style_(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            'Medicine Refill',
                            style: style_(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'As prescribed',
                            style: style_(
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (selectedQuantity > 1) {
                                setDialogState(() {
                                  selectedQuantity--;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(width * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: Colors.grey,
                                size: width * 0.05,
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.008,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                            child: Text(
                              selectedQuantity.toString(),
                              style: style_(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.06),
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedQuantity++;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(width * 0.02),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: width * 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Text(
                      'Requesting $selectedQuantity pack(s) of $medicineName',
                      style: style_(
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
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
                                  vertical: height * 0.015),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: style_(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.035,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                orderedQuantity = selectedQuantity;
                                orderedMedicineName = medicineName;
                                showSuccessNotification = true;
                              });

                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) {
                                  setState(() {
                                    showSuccessNotification = false;
                                  });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.015),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: width * 0.045,
                                ),
                                SizedBox(width: width * 0.01),
                                Text(
                                  'OK',
                                  style: style_(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.035,
                                  ),
                                ),
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
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Request prescription refills',
              style: style_(
                color: Colors.white,
                fontSize: width * 0.03,
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
                      size: width * 0.06,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      'All Prescribed Medicines',
                      style: style_(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF4CAF50)),
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
                                  fontSize: width * 0.04,
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
                        size: width * 0.06,
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
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            '$orderedMedicineName · $orderedQuantity pack(s) ordered',
                            style: style_(
                              color: Colors.white,
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w400,
                            ),
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
