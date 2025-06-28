import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';

class UserSession {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _patientIdKey = 'patientId';
  static const String _userEmailKey = 'userEmail';

  /// Save user session after successful login
  static Future<void> saveUserSession({
    required String patientId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_patientIdKey, patientId);
    await prefs.setString(_userEmailKey, email);

    // Update the data controller
    final dataController = Get.find<Datacontroller>();
    dataController.patient_ID.value = patientId;
  }

  /// Check if user is logged in and restore session
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (isLoggedIn) {
      String? patientId = prefs.getString(_patientIdKey);
      if (patientId != null) {
        // Restore patient ID in data controller
        final dataController = Get.find<Datacontroller>();
        dataController.patient_ID.value = patientId;
        return true;
      }
    }
    return false;
  }

  /// Get stored patient ID
  static Future<String?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_patientIdKey);
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Clear user session (logout)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_patientIdKey);
    await prefs.remove(_userEmailKey);

    // Clear data controller
    final dataController = Get.find<Datacontroller>();
    dataController.patient_ID.value = '';
  }
}
