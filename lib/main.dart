import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/explore_page.dart';
import 'screens/help_page.dart';
import 'screens/reserve_page.dart';
import 'screens/flight_details_page.dart';
import 'screens/flight_search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Initialize auth service to check for saved login
    await AuthService.instance.initialize();
    print('✅ Auth service initialized');
  } catch (e) {
    print('❌ Initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Reserve',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.urbanistTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => const HomePage(),
        '/login': (c) => const LoginPage(),
        '/signup': (c) => const SignupPage(),
        '/home': (c) => const HomePage(),
        '/reserve': (c) => const ReservePage(),
        '/flight_details': (c) => const FlightDetailsPage(),
        '/flight_search': (c) => const FlightSearchPage(),
        '/explore': (c) => const ExplorePage(),
        '/help': (c) => const HelpPage(),
      },
    );
  }
}
