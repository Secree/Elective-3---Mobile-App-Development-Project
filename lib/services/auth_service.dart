import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/user_db.dart';
import '../utils/security_helper.dart';

/// Authentication service to manage user login state with persistence
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  User? _currentUser;
  bool _isAuthenticated = false;
  static const String _keyUserEmail = 'user_email';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _currentUser?.email;
  String get userName => _currentUser != null 
      ? '${_currentUser!.firstName} ${_currentUser!.lastName}' 
      : 'Guest';

  /// Initialize and check for saved login state
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_keyUserEmail);
      
      if (savedEmail != null) {
        // User was previously logged in, restore their session
        final user = await UserDatabase.instance.getUserByEmail(savedEmail);
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
          notifyListeners();
        } else {
          // User no longer exists, clear saved data
          await prefs.remove(_keyUserEmail);
        }
      }
    } catch (e) {
      debugPrint('Initialize error: $e');
    }
  }

  /// Login user with password verification
  Future<bool> login(String email, String password) async {
    try {
      final user = await UserDatabase.instance.getUserByEmail(email);
      if (user != null && SecurityHelper.verifyPassword(password, user.password)) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserEmail, email);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logout user and clear saved state
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    
    // Clear saved login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
    
    notifyListeners();
  }

  /// Register new user
  Future<bool> register(User user) async {
    try {
      final existingUser = await UserDatabase.instance.getUserByEmail(user.email);
      if (existingUser != null) {
        return false; // User already exists
      }
      
      final createdUser = await UserDatabase.instance.createUser(user);
      _currentUser = createdUser;
      _isAuthenticated = true;
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, user.email);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }
}
