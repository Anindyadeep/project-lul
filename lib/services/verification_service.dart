import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationService {
  static const String _verificationKey = 'verification_data';
  static const String _isVerifiedKey = 'is_verified';

  // Save verification data
  static Future<void> saveVerificationData({
    required String inviteCode,
    required Map<String, dynamic> userInfo,
    required Map<String, dynamic> verificationInfo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final verificationData = {
      'inviteCode': inviteCode,
      'userInfo': userInfo,
      'verificationInfo': verificationInfo,
      'submittedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_verificationKey, jsonEncode(verificationData));
    // For simulation: Set verified to false initially
    await prefs.setBool(_isVerifiedKey, false);
  }

  // Check if user is verified
  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isVerifiedKey) ?? false;
  }

  // Get verification data
  static Future<Map<String, dynamic>?> getVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_verificationKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Simulate verification process (for testing)
  static Future<void> simulateVerification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isVerifiedKey, true);
  }

  // Clear all verification data
  static Future<void> clearVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationKey);
    await prefs.remove(_isVerifiedKey);
  }
}
