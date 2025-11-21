import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _tutorialCompletedKey = 'tutorial_completed';

  /// Check if the user has completed the tutorial
  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark the tutorial as completed
  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Reset tutorial status (useful for testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
}
