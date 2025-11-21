import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Flight Reserve';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeFlightSearch = '/flight_search';
  static const String routeReserve = '/reserve';
  static const String routeFlightDetails = '/flight_details';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String reservationsCollection = 'reservations';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int minAge = 18;
  static const int maxAge = 120;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Philippine Airports
  static const Map<String, String> philippineAirports = {
    'MNL': 'Manila - Ninoy Aquino International',
    'CEB': 'Cebu - Mactan-Cebu International',
    'DVO': 'Davao - Francisco Bangoy International',
    'CRK': 'Clark International Airport',
    'ILO': 'Iloilo International Airport',
    'KLO': 'Kalibo International Airport',
    'BCD': 'Bacolod-Silay Airport',
    'TAC': 'Tacloban - Daniel Z. Romualdez',
    'PPS': 'Puerto Princesa International',
    'TAG': 'Tagbilaran Airport (Bohol)',
  };
}

/// App Theme Colors
class AppColors {
  static const Color primary = Color(0xFFFF5722); // Deep Orange
  static const Color secondary = Color(0xFF2196F3); // Blue
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color background = Color(0xFFF5F5F5);
}

/// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
