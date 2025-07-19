import 'package:flutter/material.dart';
import '../../../utils/functions_uses.dart';

class MyMedicinePage extends StatefulWidget {
  const MyMedicinePage({super.key});

  @override
  State<MyMedicinePage> createState() => _MyMedicinePageState();
}

class _MyMedicinePageState extends State<MyMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final List<DiseaseInfo> _diseases = [DiseaseInfo()];

  @override
  void dispose() {
    for (var disease in _diseases) {
      disease.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double width = SizeConfig.screenWidth;
    double height = SizeConfig.screenHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: width * 0.06,
              color: Colors.white,
            ),
          ),
        ),
        leadingWidth: width * 0.15,
        title: Text(
          'My Medicines',
          style: style_(
            fontWeight: FontWeight.w900,
            fontSize: width * 0.05,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff20C65D),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade900),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color(0xffDAFFD8),
                Color(0xffFFFFFF),
              ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildSectionHeader(
                    'Medicine Management',
                    Icons.medical_services,
                    Colors.green,
                    width,
                  ),

                  SizedBox(height: height * 0.02),

                  // Medical Information Section
                  _buildMedicalInfoSection(width, height),

                  SizedBox(height: height * 0.1),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff20C65D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.1,
                          vertical: height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.05),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Save Medicines',
                        style: style_(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, Color color, double width) {
    return Container(
      margin: EdgeInsets.only(bottom: width * 0.04),
      child: Row(
        children: [
          Icon(icon, color: color, size: width * 0.07),
          SizedBox(width: width * 0.03),
          Text(
            title,
            style: style_(
              fontSize: width * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection(double width, double height) {
    return Column(
      children: [
        ..._diseases.asMap().entries.map((entry) {
          int index = entry.key;
          DiseaseInfo disease = entry.value;
          return _buildDiseaseCard(disease, index, width, height);
        }),
        SizedBox(height: height * 0.02),
        ElevatedButton.icon(
          onPressed: _addDisease,
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: width * 0.05,
          ),
          label: Text(
            'Add Disease',
            style: style_(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.04,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff20C65D),
            foregroundColor: Colors.white,
            elevation: 3,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.015,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard(
      DiseaseInfo disease, int index, double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.03),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disease ${index + 1}',
                style: style_(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              if (_diseases.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeDisease(index),
                ),
            ],
          ),
          SizedBox(height: height * 0.02),
          TextFormField(
            controller: disease.nameController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.local_hospital_outlined,
                size: width * 0.05,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.green,
                ),
              ),
              labelText: 'Disease Name *',
              labelStyle: style_(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: width * 0.035,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter disease name';
              }
              return null;
            },
          ),
          SizedBox(height: height * 0.02),
          Text(
            'Medicines',
            style: style_(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: height * 0.015),
          ...disease.medicines.asMap().entries.map((entry) {
            int medIndex = entry.key;
            Medicine medicine = entry.value;
            return _buildMedicineCard(
                disease, medicine, medIndex, width, height);
          }),
          SizedBox(height: height * 0.02),
          ElevatedButton.icon(
            onPressed: () => _addMedicine(disease),
            icon: Icon(
              Icons.add,
              size: width * 0.045,
              color: Colors.white,
            ),
            label: Text(
              'Add Medicine',
              style: style_(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.035,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff257CFF),
              foregroundColor: Colors.white,
              elevation: 3,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(DiseaseInfo disease, Medicine medicine,
      int medIndex, double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.02),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medicine ${medIndex + 1}',
                style: style_(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade900,
                ),
              ),
              if (disease.medicines.length > 1)
                IconButton(
                  icon:
                      Icon(Icons.delete, color: Colors.red, size: width * 0.05),
                  onPressed: () => setState(() {
                    disease.removeMedicine(medIndex);
                  }),
                ),
            ],
          ),
          SizedBox(height: height * 0.015),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: medicine.nameController,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name *',
                    labelStyle: style_(
                        fontSize: width * 0.035, color: Colors.grey.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.green,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: height * 0.015,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: TextFormField(
                  controller: medicine.quantityController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Quantity *',
                    labelStyle: style_(
                        fontSize: width * 0.035, color: Colors.grey.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.green,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: height * 0.015,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.02),

          // Meal Timing
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Meal Timing:',
              style: style_(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SizedBox(height: height * 0.01),
          Wrap(
            spacing: width * 0.02,
            runSpacing: height * 0.005,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.beforeMeal,
                    onChanged: (value) => setState(() {
                      medicine.beforeMeal = value!;
                    }),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'Before Meal',
                    style: style_(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.afterMeal,
                    onChanged: (value) => setState(() {
                      medicine.afterMeal = value!;
                    }),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'After Meal',
                    style: style_(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: height * 0.015),

          // Time of Day
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Time of Day:',
              style: style_(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SizedBox(height: height * 0.01),
          Wrap(
            spacing: width * 0.02,
            runSpacing: height * 0.005,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.morning,
                    onChanged: (value) => setState(() {
                      medicine.morning = value!;
                    }),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'Morning',
                    style: style_(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.afternoon,
                    onChanged: (value) => setState(() {
                      medicine.afternoon = value!;
                    }),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'Afternoon',
                    style: style_(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.evening,
                    onChanged: (value) => setState(() {
                      medicine.evening = value!;
                    }),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'Evening',
                    style: style_(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addDisease() {
    setState(() {
      _diseases.add(DiseaseInfo());
    });
  }

  void _removeDisease(int index) {
    if (_diseases.length > 1) {
      setState(() {
        _diseases[index].dispose();
        _diseases.removeAt(index);
      });
    }
  }

  void _addMedicine(DiseaseInfo disease) {
    setState(() {
      disease.addMedicine();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Collect all form data
      List<Map<String, dynamic>> diseases =
          _diseases.map((disease) => disease.toMap()).toList();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medicines saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to home page
      Navigator.pop(context);
    }
  }
}

// Data Models
class DiseaseInfo {
  final TextEditingController nameController = TextEditingController();
  List<Medicine> medicines = [Medicine()];

  void addMedicine() {
    medicines.add(Medicine());
  }

  void removeMedicine(int index) {
    if (medicines.length > 1) {
      medicines[index].dispose();
      medicines.removeAt(index);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text,
      'medicines': medicines.map((medicine) => medicine.toMap()).toList(),
    };
  }

  void dispose() {
    nameController.dispose();
    for (Medicine medicine in medicines) {
      medicine.dispose();
    }
  }
}

class Medicine {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  bool beforeMeal = false;
  bool afterMeal = false;
  bool morning = false;
  bool afternoon = false;
  bool evening = false;

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text,
      'quantity': quantityController.text,
      'timing': {
        'beforeMeal': beforeMeal,
        'afterMeal': afterMeal,
        'morning': morning,
        'afternoon': afternoon,
        'evening': evening,
      },
    };
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}
