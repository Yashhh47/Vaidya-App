import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanjeevika/services/user_session.dart';
import 'package:sanjeevika/services/medicine_status_service.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';
import 'package:get/get.dart';

class PatientDatabase {
  final data = Get.find<Datacontroller>();
  late String pid = data.patient_ID.value;

  /// Save complete patient profile to Firestore and local storage
  Future<bool> savePatientProfile(Map<String, dynamic> profileData) async {
    try {
      // Ensure we have the current patient ID
      pid = data.patient_ID.value;

      if (pid.isEmpty) {
        print('Error: Patient ID is empty');
        return false;
      }

      // Add metadata
      profileData['savedAt'] = FieldValue.serverTimestamp();
      profileData['lastModified'] = DateTime.now().toIso8601String();

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(pid)
          .set(profileData, SetOptions(merge: true));

      // Save to local storage
      await UserSession.saveProfileData(profileData);

      print(
          'Patient profile saved successfully to both Firestore and local storage');
      return true;
    } catch (e) {
      print('Error saving patient profile: $e');
      return false;
    }
  }

  /// Fetch patient profile with fallback to local storage
  Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      pid = data.patient_ID.value;

      if (pid.isEmpty) {
        print('Error: Patient ID is empty');
        return await UserSession.getLocalProfileData();
      }

      // Try to get from Firestore first
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(pid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> firestoreData = doc.data() as Map<String, dynamic>;

        // Save to local storage for offline access
        await UserSession.saveProfileData(firestoreData);

        return firestoreData;
      } else {
        // Fallback to local storage
        print('No Firestore data found, using local storage');
        return await UserSession.getLocalProfileData();
      }
    } catch (e) {
      print(
          'Error getting patient profile from Firestore, trying local storage: $e');
      // Fallback to local storage
      return await UserSession.getLocalProfileData();
    }
  }

  /// Update specific fields in patient profile
  Future<bool> updatePatientProfile(Map<String, dynamic> updatedData) async {
    try {
      pid = data.patient_ID.value;

      if (pid.isEmpty) {
        print('Error: Patient ID is empty');
        return false;
      }

      updatedData['lastModified'] = DateTime.now().toIso8601String();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(pid)
          .set(updatedData, SetOptions(merge: true));

      // Update local storage
      Map<String, dynamic>? currentData =
          await UserSession.getLocalProfileData();
      if (currentData != null) {
        // Deep merge the updated data
        _deepMerge(currentData, updatedData);
        await UserSession.saveProfileData(currentData);
      } else {
        // If no current data, save the updated data as new
        await UserSession.saveProfileData(updatedData);
      }

      return true;
    } catch (e) {
      print('Error updating patient profile: $e');
      return false;
    }
  }

  /// Helper method to deep merge maps
  void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          target[key] is Map<String, dynamic>) {
        _deepMerge(target[key], value);
      } else {
        target[key] = value;
      }
    });
  }

  /// Delete patient profile document from Firestore and local storage
  Future<bool> deletePatientProfile() async {
    try {
      pid = data.patient_ID.value;

      if (pid.isEmpty) {
        print('Error: Patient ID is empty');
        return false;
      }

      await FirebaseFirestore.instance.collection('patients').doc(pid).delete();
      await UserSession.clearUserSession();

      return true;
    } catch (e) {
      print('Error deleting patient profile: $e');
      return false;
    }
  }

  /// Get emergency contacts from profile data
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final data = await getPatientProfile();
      if (data != null && data['emergencyContacts'] != null) {
        return List<Map<String, dynamic>>.from(data['emergencyContacts']);
      }
      return [];
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  /// Get all medicines from all diseases
  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    try {
      final data = await getPatientProfile();
      if (data != null && data['diseases'] != null) {
        List<Map<String, dynamic>> allMedicines = [];
        for (var disease in data['diseases']) {
          String diseaseName = disease['name'] ?? 'Unknown Disease';
          if (disease['medicines'] != null) {
            for (var medicine in disease['medicines']) {
              allMedicines.add({
                'name': medicine['name'] ?? 'Unknown Medicine',
                'quantity': medicine['quantity'] ?? '1',
                'disease': diseaseName,
                'timing': medicine['timing'] ?? {},
              });
            }
          }
        }
        return allMedicines;
      }
      return [];
    } catch (e) {
      print('Error getting all medicines: $e');
      return [];
    }
  }

  /// Get today's medications with automatic status updates
  Future<List<Map<String, dynamic>>> getTodaysMedications() async {
    try {
      final allMedicines = await getAllMedicines();
      List<Map<String, dynamic>> todaysMedications = [];
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      for (var medicine in allMedicines) {
        Map<String, dynamic> timing = medicine['timing'] ?? {};

        // Check if medicine should be taken in morning
        if (timing['morning'] == true) {
          String status =
              MedicineStatusService.getMedicineStatus({'morning': true});
          Map<String, dynamic> morningMedicine = {
            'time': 'Morning',
            'timing':
                timing['beforeMeal'] == true ? 'Before Meal' : 'After Meal',
            'medicine': '${medicine['name']} — ${medicine['quantity']}',
            'disease': medicine['disease'],
            'status': status,
            'takenTime': '',
            'date': todayString,
          };
          todaysMedications.add(morningMedicine);

          if (status == 'missed') {
            await MedicineStatusService.addMissedMedicine(morningMedicine);
          }
        }

        // Check if medicine should be taken in afternoon
        if (timing['afternoon'] == true) {
          String status =
              MedicineStatusService.getMedicineStatus({'afternoon': true});
          Map<String, dynamic> afternoonMedicine = {
            'time': 'Afternoon',
            'timing':
                timing['beforeMeal'] == true ? 'Before Meal' : 'After Meal',
            'medicine': '${medicine['name']} — ${medicine['quantity']}',
            'disease': medicine['disease'],
            'status': status,
            'takenTime': '',
            'date': todayString,
          };
          todaysMedications.add(afternoonMedicine);

          if (status == 'missed') {
            await MedicineStatusService.addMissedMedicine(afternoonMedicine);
          }
        }

        // Check if medicine should be taken in evening
        if (timing['evening'] == true) {
          String status =
              MedicineStatusService.getMedicineStatus({'evening': true});
          Map<String, dynamic> eveningMedicine = {
            'time': 'Evening',
            'timing':
                timing['beforeMeal'] == true ? 'Before Meal' : 'After Meal',
            'medicine': '${medicine['name']} — ${medicine['quantity']}',
            'disease': medicine['disease'],
            'status': status,
            'takenTime': '',
            'date': todayString,
          };
          todaysMedications.add(eveningMedicine);

          if (status == 'missed') {
            await MedicineStatusService.addMissedMedicine(eveningMedicine);
          }
        }
      }
      return todaysMedications;
    } catch (e) {
      print('Error getting today\'s medications: $e');
      return [];
    }
  }
}
