import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';
import 'package:sanjeevika/services/patient_crud.dart';
import 'dart:convert';

class UserSession {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _patientIdKey = 'patientId';
  static const String _userEmailKey = 'userEmail';
  static const String _profileDataKey = 'profileData';
  static const String _lastSyncKey = 'lastSync';

  /// Save user session with complete profile data
  static Future<void> saveUserSession({
    required String patientId,
    required String email,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save basic session info
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_patientIdKey, patientId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      // Save profile data if provided
      if (profileData != null) {
        await prefs.setString(_profileDataKey, jsonEncode(profileData));
      }

      // Update the data controller
      final dataController = Get.find<Datacontroller>();
      dataController.patient_ID.value = patientId;
      dataController.set_patient_email(email);

      print('Enhanced user session saved successfully: $patientId, $email');
    } catch (e) {
      print('Error saving enhanced user session: $e');
    }
  }

  /// Save profile data to local storage
  static Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileDataKey, jsonEncode(profileData));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      print('Profile data saved to local storage');
    } catch (e) {
      print('Error saving profile data: $e');
    }
  }

  /// Get profile data from local storage
  static Future<Map<String, dynamic>?> getLocalProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileDataString = prefs.getString(_profileDataKey);

      if (profileDataString != null) {
        return jsonDecode(profileDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting local profile data: $e');
      return null;
    }
  }

  /// Check if user is logged in and restore complete session
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn) {
        String? patientId = prefs.getString(_patientIdKey);
        String? email = prefs.getString(_userEmailKey);

        if (patientId != null && patientId.isNotEmpty) {
          // Restore patient ID and email in data controller
          final dataController = Get.find<Datacontroller>();
          dataController.patient_ID.value = patientId;

          if (email != null && email.isNotEmpty) {
            dataController.set_patient_email(email);
          }

          // Try to sync with Firestore and update local data
          await _syncProfileData();

          print('Enhanced user session restored: $patientId, $email');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking enhanced user session: $e');
      return false;
    }
  }

  /// Update user profile information in session - MISSING METHOD ADDED
  static Future<void> updateUserProfileInSession({
    String? name,
    String? phone,
    String? dob,
    String? bloodGroup,
    String? email,
    String? address,
    String? gender,
    int? age,
  }) async {
    try {
      final dataController = Get.find<Datacontroller>();

      // Update data controller values
      if (name != null) {
        dataController.set_patient_name(name);
      }
      if (phone != null) {
        dataController.set_patient_phonenumber(phone);
      }
      if (dob != null) {
        dataController.set_patient_dob(dob);
      }
      if (bloodGroup != null) {
        dataController.set_patient_blood_group(bloodGroup);
      }
      if (email != null) {
        dataController.set_patient_email(email);
      }

      // Get current profile data and update it
      Map<String, dynamic>? currentProfileData = await getLocalProfileData();
      if (currentProfileData != null) {
        // Update personal info in the profile data
        if (currentProfileData['personalInfo'] == null) {
          currentProfileData['personalInfo'] = {};
        }

        Map<String, dynamic> personalInfo = currentProfileData['personalInfo'];

        if (name != null) personalInfo['name'] = name;
        if (phone != null) personalInfo['phone'] = phone;
        if (dob != null) personalInfo['dateOfBirth'] = dob;
        if (bloodGroup != null) personalInfo['bloodGroup'] = bloodGroup;
        if (email != null) personalInfo['email'] = email;
        if (address != null) personalInfo['address'] = address;
        if (gender != null) personalInfo['gender'] = gender;
        if (age != null) personalInfo['age'] = age;

        // Save updated profile data
        await saveProfileData(currentProfileData);
      }

      print('User profile updated in session successfully');
    } catch (e) {
      print('Error updating user profile in session: $e');
    }
  }

  /// Sync profile data from Firestore to local storage
  static Future<void> _syncProfileData() async {
    try {
      final patientDatabase = PatientDatabase();
      final firestoreData = await patientDatabase.getPatientProfile();

      if (firestoreData != null) {
        await saveProfileData(firestoreData);
        print('Profile data synced from Firestore');
      }
    } catch (e) {
      print('Error syncing profile data: $e');
    }
  }

  /// Get stored patient ID
  static Future<String?> getPatientId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_patientIdKey);
    } catch (e) {
      print('Error getting patient ID: $e');
      return null;
    }
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  /// Clear user session (logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_patientIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_profileDataKey);
      await prefs.remove(_lastSyncKey);

      // Clear data controller
      final dataController = Get.find<Datacontroller>();
      dataController.patient_ID.value = '';

      print('Enhanced user session cleared successfully');
    } catch (e) {
      print('Error clearing enhanced user session: $e');
    }
  }

  /// Check if user session exists without restoring it
  static Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      String? patientId = prefs.getString(_patientIdKey);
      return isLoggedIn && patientId != null && patientId.isNotEmpty;
    } catch (e) {
      print('Error checking session validity: $e');
      return false;
    }
  }

  /// Force sync profile data from Firestore
  static Future<Map<String, dynamic>?> forceSync() async {
    try {
      await _syncProfileData();
      return await getLocalProfileData();
    } catch (e) {
      print('Error in force sync: $e');
      return null;
    }
  }

  /// Update session email
  static Future<void> updateSessionEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);

      final dataController = Get.find<Datacontroller>();
      dataController.set_patient_email(email);

      print('Session email updated successfully');
    } catch (e) {
      print('Error updating session email: $e');
    }
  }

  /// Get current session info
  static Future<Map<String, String?>> getCurrentSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'patientId': prefs.getString(_patientIdKey),
        'email': prefs.getString(_userEmailKey),
        'lastSync': prefs.getString(_lastSyncKey),
      };
    } catch (e) {
      print('Error getting current session info: $e');
      return {
        'patientId': null,
        'email': null,
        'lastSync': null,
      };
    }
  }
}
