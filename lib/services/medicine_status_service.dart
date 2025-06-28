import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicineStatusService {
  static const String _missedMedicinesKey = 'missedMedicines';
  static const String _dismissedNotificationsKey = 'dismissedNotifications';

  /// Update medicine status based on current time
  static String getMedicineStatus(Map<String, dynamic> timing) {
    final now = DateTime.now();
    final currentHour = now.hour;

    bool morningTime = timing['morning'] == true;
    bool afternoonTime = timing['afternoon'] == true;
    bool eveningTime = timing['evening'] == true;

    // Morning: 6 AM - 12 PM
    // Afternoon: 12 PM - 6 PM
    // Evening: 6 PM - 10 PM

    if (morningTime && currentHour >= 12) {
      return 'missed'; // Morning time passed
    }
    if (afternoonTime && currentHour >= 18) {
      return 'missed'; // Afternoon time passed
    }
    if (eveningTime && currentHour >= 22) {
      return 'missed'; // Evening time passed
    }

    return 'pending';
  }

  /// Save missed medicines to local storage
  static Future<void> saveMissedMedicines(
      List<Map<String, dynamic>> missedMedicines) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(missedMedicines);
    await prefs.setString(_missedMedicinesKey, encodedData);
  }

  /// Get missed medicines from local storage
  static Future<List<Map<String, dynamic>>> getMissedMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_missedMedicinesKey);

    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      return decodedData.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Add a missed medicine
  static Future<void> addMissedMedicine(Map<String, dynamic> medicine) async {
    final missedMedicines = await getMissedMedicines();

    // Check if already exists (avoid duplicates)
    bool exists = missedMedicines.any((m) =>
        m['medicine'] == medicine['medicine'] &&
        m['time'] == medicine['time'] &&
        m['date'] == medicine['date']);

    if (!exists) {
      missedMedicines.add(medicine);
      await saveMissedMedicines(missedMedicines);
    }
  }

  /// Remove a missed medicine (when dismissed)
  static Future<void> removeMissedMedicine(int index) async {
    final missedMedicines = await getMissedMedicines();
    if (index >= 0 && index < missedMedicines.length) {
      missedMedicines.removeAt(index);
      await saveMissedMedicines(missedMedicines);
    }
  }

  /// Clear all missed medicines
  static Future<void> clearAllMissedMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_missedMedicinesKey);
  }
}
