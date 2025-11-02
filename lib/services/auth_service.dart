import 'package:flutter/foundation.dart';
import '../db/user_db.dart';

/// Authentication service to manage user login state
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _currentUser?.email;
  String get userName => _currentUser != null 
      ? '${_currentUser!.firstName} ${_currentUser!.lastName}' 
      : 'Guest';

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      final user = await UserDatabase.instance.getUserByEmail(email);
      if (user != null && user.password == password) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logout user
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
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
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }
}
