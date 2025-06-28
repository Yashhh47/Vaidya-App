import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sanjeevika/view/widgets/common/loading_screen.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import '../../../viewmodels/data_controller.dart';
import 'package:get/get.dart';
import '../home/home_page.dart';
import '../../../services/data_fucntions.dart';

class InformationForm extends StatefulWidget {
  @override
  _InformationFormState createState() => _InformationFormState();
}

final data = Get.find<Datacontroller>();

class _InformationFormState extends State<InformationForm> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedBloodGroup = '';
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  // Profile Image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Disease and Medicine Information
  List<DiseaseInfo> _diseases = [DiseaseInfo()];

  // Emergency Contacts
  List<EmergencyContact> _emergencyContacts = [EmergencyContact()];

  // Loading state
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  // Load existing data from Firestore
  Future<void> _loadExistingData() async {
    try {
      final patientDatabase = PatientDatabase();
      final profileData = await patientDatabase.getPatientProfile();

      if (profileData != null) {
        // Load personal info
        if (profileData['personalInfo'] != null) {
          final personalInfo = profileData['personalInfo'];
          _nameController.text = personalInfo['name'] ?? '';
          _phoneController.text = personalInfo['phone'] ?? '';
          _dobController.text = personalInfo['dateOfBirth'] ?? '';
          _selectedBloodGroup = personalInfo['bloodGroup'] ?? '';

          // Set data controller values
          data.set_patient_name(personalInfo['name'] ?? '');
          data.set_patient_phonenumber(personalInfo['phone'] ?? '');
          data.set_patient_dob(personalInfo['dateOfBirth'] ?? '');
          data.set_patient_blood_group(personalInfo['bloodGroup'] ?? '');
        }

        // Load diseases and medicines
        if (profileData['diseases'] != null &&
            profileData['diseases'].isNotEmpty) {
          _diseases.clear();
          for (var diseaseData in profileData['diseases']) {
            DiseaseInfo disease = DiseaseInfo();
            disease.nameController.text = diseaseData['name'] ?? '';

            if (diseaseData['medicines'] != null &&
                diseaseData['medicines'].isNotEmpty) {
              disease.medicines.clear();
              for (var medicineData in diseaseData['medicines']) {
                Medicine medicine = Medicine();
                medicine.nameController.text = medicineData['name'] ?? '';
                medicine.quantityController.text =
                    medicineData['quantity'] ?? '';

                if (medicineData['timing'] != null) {
                  medicine.beforeMeal =
                      medicineData['timing']['beforeMeal'] ?? false;
                  medicine.afterMeal =
                      medicineData['timing']['afterMeal'] ?? false;
                  medicine.morning = medicineData['timing']['morning'] ?? false;
                  medicine.afternoon =
                      medicineData['timing']['afternoon'] ?? false;
                  medicine.evening = medicineData['timing']['evening'] ?? false;
                }
                disease.medicines.add(medicine);
              }
            }
            _diseases.add(disease);
          }
        }

        // Load emergency contacts
        if (profileData['emergencyContacts'] != null &&
            profileData['emergencyContacts'].isNotEmpty) {
          _emergencyContacts.clear();
          for (var contactData in profileData['emergencyContacts']) {
            EmergencyContact contact = EmergencyContact();
            contact.nameController.text = contactData['name'] ?? '';
            contact.phoneController.text = contactData['phone'] ?? '';
            _emergencyContacts.add(contact);
          }
        }
      }

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error loading existing data: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  double size = data.size;
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(size / 10)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Container(
            padding: EdgeInsets.all(size / 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    fontSize: size / 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: size / 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _getImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(size / 25),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(size / 25),
                            ),
                            child: Icon(
                              Icons.linked_camera_outlined,
                              size: size / 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: size / 30),
                          Text(
                            'Camera',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size / 25),
                          ),
                        ],
                      ),
                    ),
                    if (_profileImage == null)
                      SizedBox(
                        height: 0,
                        width: size / 25,
                      ),
                    GestureDetector(
                      onTap: () {
                        _getImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(size / 25),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(size / 25),
                            ),
                            child: Icon(
                              Icons.photo_library_outlined,
                              size: size / 10,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: size / 30),
                          Text(
                            'Gallery',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size / 25),
                          ),
                        ],
                      ),
                    ),
                    if (_profileImage != null)
                      GestureDetector(
                        onTap: () {
                          _removeImage();
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(size / 25),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(size / 25),
                              ),
                              child: Icon(
                                Icons.delete,
                                size: size / 10,
                                color: Colors.red.shade700,
                              ),
                            ),
                            SizedBox(height: size / 30),
                            Text(
                              'Remove',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size / 25),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: size / 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _profileImage = null;
    });
  }

  void _addDisease() {
    setState(() {
      _diseases.add(DiseaseInfo());
    });
  }

  void _removeDisease(int index) {
    if (_diseases.length > 1) {
      setState(() {
        _diseases.removeAt(index);
      });
    }
  }

  void _addEmergencyContact() {
    setState(() {
      _emergencyContacts.add(EmergencyContact());
    });
  }

  void _removeEmergencyContact(int index) {
    if (_emergencyContacts.length > 1) {
      setState(() {
        _emergencyContacts.removeAt(index);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String name = data.patient_name.value;
      String dobb = data.patient_dob.value;
      String bloodgroupp = data.patient_blood_group.value;

      String pateint_id = getPatientID(name, dobb, bloodgroupp);

      data.set_patient_ID(pateint_id);

      // Collect all form data
      Map<String, dynamic> formData = {
        'personalInfo': {
          'name': _nameController.text,
          'bloodGroup': _selectedBloodGroup,
          'phone': _phoneController.text,
          'dateOfBirth': _dobController.text,
          'profileImagePath': _profileImage?.path ?? 'profile_image.png',
        },
        'diseases': _diseases.map((disease) => disease.toMap()).toList(),
        'emergencyContacts':
            _emergencyContacts.map((contact) => contact.toMap()).toList(),
      };

      // Save the collected form data to Firestore using the PatientDatabase service.
      // This returns true if the data was saved successfully, or false if there was an error.
      final patientDatabase = PatientDatabase();
      bool success = await patientDatabase.savePatientProfile(formData);

      navigateWithLoading();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildProfileImageSection() {
    double size = data.size;
    return Container(
      margin: EdgeInsets.only(bottom: size / 20),
      child: Center(
        child: GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: size / 3,
            height: size / 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.green.shade300,
                width: 4,
              ),
            ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      width: size / 3,
                      height: size / 3,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/images/profile_image.png',
                      width: size / 3,
                      height: size / 3,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: size / 3,
                          height: size / 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: Icon(
                            Icons.person,
                            size: size / 5,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = data.size;

    // Show loading screen while data is being loaded
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: size / 35),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                size: size / 12,
                color: Colors.white,
              ),
            ),
          ),
          leadingWidth: size / 6,
          title: Text(
            'Edit Patient Details',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: size / 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xff20C65D),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.green.shade900),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff20C65D)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: size / 35),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              size: size / 12,
              color: Colors.white, // Make sure icon is visible
            ),
          ),
        ),
        leadingWidth:
            size / 6, // ✅ Increased from /10 to /6 for better tap area
        title: Text(
          'Edit Patient Details',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: size / 18,
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
              ])),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(size / 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(),

                  // Personal Information Section
                  _buildSectionHeader(
                      'Personal Information', Icons.person, Colors.blue),
                  _buildPersonalInfoSection(),

                  SizedBox(height: size / 10),

                  // Medical Information Section
                  _buildSectionHeader('Medical Information',
                      Icons.medical_services, Colors.green),
                  _buildMedicalInfoSection(),

                  SizedBox(height: size / 10),

                  // Emergency Contacts Section
                  _buildSectionHeader(
                    'Emergency Contacts',
                    Icons.warning_amber,
                    Colors.red,
                  ),
                  _buildEmergencyContactsSection(),

                  SizedBox(height: size / 5),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff20C65D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: size / 10, vertical: size / 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(size / 5),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Save Information',
                        style: TextStyle(
                            fontSize: size / 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: size / 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    double size = data.size;
    return Container(
      margin: EdgeInsets.only(bottom: size / 25),
      child: Row(
        children: [
          Icon(icon, color: color, size: size / 12),
          SizedBox(width: size / 35),
          Text(
            title,
            style: TextStyle(
              fontSize: size / 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    double size = data.size;
    return Container(
      padding: EdgeInsets.all(size / 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Full Name *',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: Icon(Icons.person_outline, size: size / 15),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                data.set_patient_name(value.toString().toUpperCase());
              });
            },
          ),
          SizedBox(height: size / 25),
          DropdownButtonFormField<String>(
            value: _selectedBloodGroup.isEmpty ? null : _selectedBloodGroup,
            decoration: InputDecoration(
              labelText: 'Blood Group *',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: Icon(Icons.bloodtype_outlined, size: size / 15),
            ),
            items: _bloodGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodGroup = newValue!;
                data.set_patient_blood_group(newValue.toString().toUpperCase());
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select blood group';
              }
              return null;
            },
            onSaved: (value) {
              data.set_patient_blood_group(value.toString().toUpperCase());
            },
          ),
          SizedBox(height: size / 25),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone, size: size / 15),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Phone Number (optional)',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              if (value == null) {
                setState(() {
                  data.set_patient_phonenumber('');
                });
              } else {
                setState(() {
                  data.set_patient_phonenumber(value.toString());
                });
              }
            },
          ),
          SizedBox(height: size / 25),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today_outlined, size: size / 15),
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_month, size: size / 15),
                onPressed: _selectDate,
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Date of Birth *',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onTap: _selectDate,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select date of birth';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                data.set_patient_dob(value.toString().toUpperCase());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    double size = data.size;
    return Column(
      children: [
        ..._diseases.asMap().entries.map((entry) {
          int index = entry.key;
          DiseaseInfo disease = entry.value;
          return _buildDiseaseCard(disease, index);
        }).toList(),
        SizedBox(height: size / 65),
        ElevatedButton.icon(
          onPressed: _addDisease,
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: size / 20,
          ),
          label: Text(
            'Add Disease',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size / 25),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff20C65D),
            foregroundColor: Colors.white,
            elevation: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard(DiseaseInfo disease, int index) {
    double size = data.size;
    return Container(
      margin: EdgeInsets.only(bottom: size / 15),
      padding: EdgeInsets.all(size / 15),
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
                style: TextStyle(
                  fontSize: size / 20,
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
          SizedBox(height: size / 20),
          TextFormField(
            controller: disease.nameController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.local_hospital_outlined,
                size: size / 15,
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Disease Name *',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
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
          SizedBox(height: size / 25),
          Text(
            'Medicines',
            style: TextStyle(
              fontSize: size / 25,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: size / 35),
          ...disease.medicines.asMap().entries.map((entry) {
            int medIndex = entry.key;
            Medicine medicine = entry.value;
            return _buildMedicineCard(disease, medicine, medIndex);
          }).toList(),
          SizedBox(height: size / 45),
          ElevatedButton.icon(
            onPressed: () => disease.addMedicine(),
            icon: Icon(
              Icons.add,
              size: size / 20,
              color: Colors.white,
            ),
            label: Text(
              'Add Medicine',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: size / 25),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff257CFF),
              foregroundColor: Colors.white,
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(
      DiseaseInfo disease, Medicine medicine, int medIndex) {
    double size = data.size;
    return Container(
      margin: EdgeInsets.only(bottom: size / 20),
      padding: EdgeInsets.all(size / 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(size / 25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medicine ${medIndex + 1}',
                style: TextStyle(
                  fontSize: size / 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade900,
                ),
              ),
              if (disease.medicines.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: size / 15),
                  onPressed: () => setState(() {
                    disease.removeMedicine(medIndex);
                  }),
                ),
            ],
          ),
          SizedBox(height: size / 35),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: medicine.nameController,
                  decoration: InputDecoration(
                    labelText: 'Med. Name *',
                    labelStyle: TextStyle(fontSize: size / 25),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(size / 35),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.green,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(size / 35),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: size / 25),
              Expanded(
                child: TextFormField(
                  controller: medicine.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity *',
                    labelStyle: TextStyle(fontSize: size / 25),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(size / 35),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.green,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(size / 35),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          SizedBox(height: size / 30),

          // Meal Timing
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Meal Timing:',
                style: TextStyle(
                    fontSize: size / 25, fontWeight: FontWeight.w900)),
          ),
          Wrap(
            spacing: size / 55,
            runSpacing: size / 35,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.beforeMeal,
                    onChanged: (value) => setState(() {
                      medicine.beforeMeal = value!;
                    }),
                  ),
                  Text('Before Meal',
                      style: TextStyle(
                          fontSize: size / 25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold)),
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
                  ),
                  Text('After Meal',
                      style: TextStyle(
                          fontSize: size / 25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          SizedBox(height: size / 40),

          // Time of Day (FIXED)
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Time of Day:',
                style: TextStyle(
                    fontSize: size / 25, fontWeight: FontWeight.w900)),
          ),
          Wrap(
            spacing: size / 15,
            runSpacing: size / 85,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.morning,
                    onChanged: (value) => setState(() {
                      medicine.morning = value!;
                    }),
                  ),
                  Text('Morning',
                      style: TextStyle(
                          fontSize: size / 25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold)),
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
                  ),
                  Text('Afternoon',
                      style: TextStyle(
                          fontSize: size / 25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold)),
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
                  ),
                  Text('Evening',
                      style: TextStyle(
                          fontSize: size / 25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    double size = data.size;
    return Column(
      children: [
        ..._emergencyContacts.asMap().entries.map((entry) {
          int index = entry.key;
          EmergencyContact contact = entry.value;
          return _buildEmergencyContactCard(contact, index);
        }).toList(),
        SizedBox(height: size / 55),
        ElevatedButton.icon(
          onPressed: _addEmergencyContact,
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: size / 15,
          ),
          label: Text(
            'Add Contact',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size / 25),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffFF4444),
            foregroundColor: Colors.white,
            elevation: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact, int index) {
    double size = data.size;
    return Container(
      margin: EdgeInsets.only(bottom: size / 25),
      padding: EdgeInsets.all(size / 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency Contact ${index + 1}',
                style: TextStyle(
                  fontSize: size / 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.red.shade700,
                ),
              ),
              if (_emergencyContacts.length > 1)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: size / 15,
                  ),
                  onPressed: () => _removeEmergencyContact(index),
                ),
            ],
          ),
          SizedBox(height: size / 35),
          TextFormField(
            controller: contact.nameController,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Contact Name *',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact name';
              }
              return null;
            },
          ),
          SizedBox(height: size / 25),
          TextFormField(
            controller: contact.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(size / 30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              labelText: 'Phone Number *',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size / 30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
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

class EmergencyContact {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text,
      'phone': phoneController.text,
    };
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
  }
}

void navigateWithLoading() async {
  // Show the loading screen as a full dialog
  Get.dialog(
    loading_screen(),
    barrierDismissible: false,
  );

  // Wait for 3 seconds (or any async task)
  await Future.delayed(const Duration(seconds: 3));

  // Close the loading dialog
  Get.back();

  Get.offAll(() => HomePage(),
      transition: Transition.fade, duration: Duration(milliseconds: 350));
}
