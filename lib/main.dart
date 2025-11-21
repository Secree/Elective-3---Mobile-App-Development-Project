import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/explore_page.dart';
import 'screens/help_page.dart';
import 'screens/reserve_page.dart';
import 'screens/flight_details_page.dart';
import 'screens/flight_search_page.dart';
import 'screens/tutorial_page.dart';
import 'screens/seat_selection_page.dart';
import 'screens/payment_page.dart';

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
      home: const InitialLoadingScreen(),
      routes: {
        '/tutorial': (c) => const TutorialPage(),
        '/login': (c) => const LoginPage(),
        '/signup': (c) => const SignupPage(),
        '/home': (c) => const HomePage(),
        '/reserve': (c) => const ReservePage(),
        '/flight_details': (c) => const FlightDetailsPage(),
        '/flight_search': (c) => const FlightSearchPage(),
        '/explore': (c) => const ExplorePage(),
        '/help': (c) => const HelpPage(),
        '/seat_selection': (c) => const SeatSelectionPage(),
        '/payment': (c) => const PaymentPage(),
      },
    );
  }
}

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));

    final hasSeenTutorial = await OnboardingService.hasSeen();

    if (mounted) {
      if (hasSeenTutorial) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacementNamed('/tutorial');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airlines,
              size: isSmallScreen ? 60 : 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
            Text(
              'Flight Reserve',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: isSmallScreen ? 20 : null,
                  ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
