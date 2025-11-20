import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../db/reservation_db.dart';
import '../db/user_db.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Reservation> _reservations = [];
  String? _loadedForEmail; // Track which user's data is loaded
  String? _userFullName; // cached user's first + last name
  int _selectedIndex = 0;
  // Carousel state for the simple image placeholder carousel
  late PageController _carouselController;
  int _carouselIndex = 0;
  // Additional carousels for logged-in users
  late PageController _exploreCarouselController;
  int _exploreCarouselIndex = 0;
  late PageController _dealsCarouselController;
  int _dealsCarouselIndex = 0;
  // Map of placeholder id -> caption. Using a map lets us associate each
  // placeholder with metadata later (e.g., image asset or network URL).
  final Map<String, String> _carouselItems = {
    '24/7 Support':
        'Never feel alone while you travel; we are always just a tap away. Our friendly support team is here around the clock to answer your questions and keep you moving forward.',
    'Competitive Fares Guaranteed':
        'Make that dream trip a reality without the stress of high costs. We believe exploring the world should be accessible to everyone, which is why we guarantee the best value on every flight.',
    'Your Safety is Our Priority':
        'Fly with true peace of mind knowing we put your well-being above everything else. We take care of the safety details so you can simply relax and enjoy the journey.',
  };
  // Corresponding image asset file names for the carousel (in lib/image/)
  final List<String> _carouselImages = [
    'lib/image/carousel_pic1.jpg',
    'lib/image/carousel_pic2.jpg',
    'lib/image/carousel_pic3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _exploreCarouselController = PageController();
    _dealsCarouselController = PageController();
    // Check if user is already logged in from AuthService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _exploreCarouselController.dispose();
    _dealsCarouselController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    final authService = AuthService.instance;
    if (authService.isAuthenticated && authService.userEmail != null) {
      // User is logged in, navigate to home with email
      final email = authService.userEmail!;
      if (mounted && ModalRoute.of(context)?.settings.arguments == null) {
        Navigator.of(context).pushReplacementNamed('/home', arguments: email);
      }
    }
  }

  Future<void> _load(String userEmail) async {
    final list = await ReservationDatabase.instance.getByUserId(userEmail);
    setState(() {
      _reservations = list;
      _loadedForEmail = userEmail; // Track that we loaded for this user
    });
  }

  Future<void> _loadUserName(String userEmail) async {
    try {
      final user = await UserDatabase.instance.getUserByEmail(userEmail);
      if (user != null) {
        setState(() {
          _userFullName = '${user.firstName} ${user.lastName}';
        });
      }
    } catch (_) {
      // ignore errors; leave _userFullName null so UI falls back to email
    }
  }

  Future<void> _goFlightSearch(String userEmail) async {
    await Navigator.of(context)
        .pushNamed('/flight_search', arguments: userEmail);
    // Refresh reservations when returning
    await _load(userEmail);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String?;
    final isLoggedIn = email != null;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 500;
    final isVerySmallScreen = screenWidth < 400;

    // Limit layout to an ideal phone width for better readability on large screens
    final idealWidth = screenWidth > 420 ? 420.0 : screenWidth;

    final baseCardHorizontal = math.min(32.0, idealWidth * 0.06);
    final baseCardVertical = math.min(20.0, idealWidth * 0.04);

    final cardHorizontalPadding = isVerySmallScreen
        ? math.max(12.0, baseCardHorizontal * 0.85)
        : baseCardHorizontal;
    final cardVerticalPadding = isVerySmallScreen
        ? math.max(10.0, baseCardVertical * 0.85)
        : baseCardVertical;

    // Horizontal gap between the card area and screen edges. This ensures
    // a consistent margin on all devices and scales with available space.
    final outerHorizontalGap = math.max(12.0, (screenWidth - idealWidth) / 2);

    // Load reservations and user name if we haven't loaded for this user yet
    if (isLoggedIn) {
      if (_loadedForEmail != email) {
        Future.microtask(() => _load(email));
      }
      if (_userFullName == null || _loadedForEmail != email) {
        Future.microtask(() => _loadUserName(email));
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logged-in layout: background image (1/3 screen), circular avatar, greeting, button, manage flights card
                if (isLoggedIn) ...[
                  SizedBox(
                    width: screenWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background image occupying 1/3 of screen
                        Image.asset(
                          'lib/image/el_nido_bg1.jpg',
                          fit: BoxFit.cover,
                          width: screenWidth,
                          height: screenHeight / 3,
                        ),
                        // LIPAD logo at top
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            child: Center(
                              child: Text(
                                'LIPAD',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                  fontSize: 36,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Circular user image placeholder - upper half overlaps bottom of background
                        Positioned(
                          top: (screenHeight / 3) -
                              50, // Position so upper half overlaps
                          left: (screenWidth / 2) - 50, // Center horizontally
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 60), // Space for the overlapping circle
                  // Greeting
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerHorizontalGap),
                    child: Text(
                      'Hello, ${_userFullName?.split(' ').first ?? 'User'}!',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Book flight button
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerHorizontalGap),
                    child: FilledButton.icon(
                      onPressed: () => _goFlightSearch(email),
                      icon: const Icon(Icons.search, size: 22),
                      label: const Text('Book a Flight'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Manage flights card
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerHorizontalGap),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Manage Flights',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Icon(
                                  Icons.flight,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_reservations.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.flight_takeoff,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No flights booked yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...List.generate(
                                math.min(3, _reservations.length),
                                (index) {
                                  final reservation = _reservations[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context)
                                                  .pushNamed(
                                            '/flight_details',
                                            arguments: reservation,
                                          );
                                          if (result == true) {
                                            await _load(email!);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          reservation.from,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        if (reservation
                                                                .airline !=
                                                            null)
                                                          Text(
                                                            reservation
                                                                .airline!,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          reservation.to,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        if (reservation
                                                                .flightNumber !=
                                                            null)
                                                          Text(
                                                            reservation
                                                                .flightNumber!,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Booked: ${_formatDate(reservation.createdAt)}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey[400],
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (_reservations.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    '+ ${_reservations.length - 3} more flights',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // First new container: Promos & Deals
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerHorizontalGap),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promos & Deals',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Icon(
                                  Icons.local_offer,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PageView.builder(
                                    controller: _exploreCarouselController,
                                    onPageChanged: (index) => setState(
                                        () => _exploreCarouselIndex = index),
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Image placeholder
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Image.asset(
                                                  index == 0
                                                      ? 'lib/image/pd1.jpg'
                                                      : 'lib/image/pd2.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Caption
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Promo ${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextButton(
                                                    onPressed: () {},
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize:
                                                          const Size(0, 0),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: const Text('More'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  // Left arrow - centered on image placeholder
                                  Positioned(
                                    left: 0,
                                    top: (280 * 3 / 4) / 2 -
                                        24, // Center on image area (flex:3 portion)
                                    child: Opacity(
                                      opacity:
                                          _exploreCarouselIndex > 0 ? 1.0 : 0.5,
                                      child: IconButton(
                                        onPressed: _exploreCarouselIndex > 0
                                            ? () {
                                                _exploreCarouselController
                                                    .previousPage(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            : null,
                                        icon: const CircleAvatar(
                                          backgroundColor: Colors.black45,
                                          child: Icon(Icons.chevron_left,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Right arrow - centered on image placeholder
                                  Positioned(
                                    right: 0,
                                    top: (280 * 3 / 4) / 2 -
                                        24, // Center on image area (flex:3 portion)
                                    child: Opacity(
                                      opacity:
                                          _exploreCarouselIndex < 1 ? 1.0 : 0.5,
                                      child: IconButton(
                                        onPressed: _exploreCarouselIndex < 1
                                            ? () {
                                                _exploreCarouselController
                                                    .nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            : null,
                                        icon: const CircleAvatar(
                                          backgroundColor: Colors.black45,
                                          child: Icon(Icons.chevron_right,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Second new container: Travel Tips
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerHorizontalGap),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Travel Tips',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Icon(
                                  Icons.tips_and_updates,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PageView.builder(
                                    controller: _dealsCarouselController,
                                    onPageChanged: (index) => setState(
                                        () => _dealsCarouselIndex = index),
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Image placeholder
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Image.asset(
                                                  index == 0
                                                      ? 'lib/image/tip1.jpg'
                                                      : 'lib/image/tip2.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Caption
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tip ${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextButton(
                                                    onPressed: () {},
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize:
                                                          const Size(0, 0),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: const Text('More'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  // Left arrow - centered on image placeholder
                                  Positioned(
                                    left: 0,
                                    top: (280 * 3 / 4) / 2 -
                                        24, // Center on image area (flex:3 portion)
                                    child: Opacity(
                                      opacity:
                                          _dealsCarouselIndex > 0 ? 1.0 : 0.5,
                                      child: IconButton(
                                        onPressed: _dealsCarouselIndex > 0
                                            ? () {
                                                _dealsCarouselController
                                                    .previousPage(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            : null,
                                        icon: const CircleAvatar(
                                          backgroundColor: Colors.black45,
                                          child: Icon(Icons.chevron_left,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Right arrow - centered on image placeholder
                                  Positioned(
                                    right: 0,
                                    top: (280 * 3 / 4) / 2 -
                                        24, // Center on image area (flex:3 portion)
                                    child: Opacity(
                                      opacity:
                                          _dealsCarouselIndex < 1 ? 1.0 : 0.5,
                                      child: IconButton(
                                        onPressed: _dealsCarouselIndex < 1
                                            ? () {
                                                _dealsCarouselController
                                                    .nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            : null,
                                        icon: const CircleAvatar(
                                          backgroundColor: Colors.black45,
                                          child: Icon(Icons.chevron_right,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]
                // Logged-out layout: full-screen hero with centered card
                else ...[
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'lib/image/el_nido_bg1.jpg',
                          fit: BoxFit.cover,
                          width: screenWidth,
                          height: screenHeight,
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            child: Center(
                              child: Text(
                                'LIPAD',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                  fontSize: 36,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: outerHorizontalGap,
                              ),
                              child: SizedBox(
                                width: idealWidth,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'El Nido, Palawan',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: isSmallScreen ? 54 : 96,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(0, 2),
                                            blurRadius: 6,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 20),
                                    Card(
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: cardHorizontalPadding,
                                          vertical: cardVerticalPadding,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.airlines,
                                                  size: isSmallScreen ? 28 : 36,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Text(
                                                    'Visit this featured spot now!',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            FilledButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please login to search flights'),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                Navigator.of(context)
                                                    .pushNamed('/login');
                                              },
                                              icon: Icon(Icons.search,
                                                  size:
                                                      isSmallScreen ? 18 : 22),
                                              label: const Text('Book Flights'),
                                              style: FilledButton.styleFrom(
                                                minimumSize: Size(
                                                    double.infinity,
                                                    isSmallScreen ? 44 : 54),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Wrap(
                                              alignment: WrapAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed('/login');
                                                  },
                                                  child: const Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const Text(' or '),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed('/signup');
                                                  },
                                                  child: const Text(
                                                    'Signup',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const Text(
                                                    ' now to use all features!'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Carousel section - only shown when user is not logged in
                if (!isLoggedIn)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Why Choose Us?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Carousel with arrow navigation
                      SizedBox(
                        height: isSmallScreen ? 160 : 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _carouselController,
                              itemCount: _carouselItems.length,
                              onPageChanged: (idx) =>
                                  setState(() => _carouselIndex = idx),
                              itemBuilder: (context, idx) {
                                final imagePath = idx < _carouselImages.length
                                    ? _carouselImages[idx]
                                    : null;
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.transparent,
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: imagePath != null
                                      ? Image.asset(
                                          imagePath,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.image,
                                            size: isSmallScreen ? 48 : 72,
                                            color: Colors.white70,
                                          ),
                                        ),
                                );
                              },
                            ),

                            // Left arrow
                            Positioned(
                              left: 8,
                              child: Opacity(
                                opacity: _carouselIndex > 0 ? 1.0 : 0.5,
                                child: IconButton(
                                  onPressed: _carouselIndex > 0
                                      ? () {
                                          _carouselController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    child: Icon(Icons.chevron_left,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            // Right arrow
                            Positioned(
                              right: 8,
                              child: Opacity(
                                opacity:
                                    _carouselIndex < _carouselItems.length - 1
                                        ? 1.0
                                        : 0.5,
                                child: IconButton(
                                  onPressed:
                                      _carouselIndex < _carouselItems.length - 1
                                          ? () {
                                              _carouselController.nextPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    child: Icon(Icons.chevron_right,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _carouselItems.keys.elementAt(_carouselIndex),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Text placeholder that updates with the carousel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _carouselItems.values.elementAt(_carouselIndex),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            // Book/Search
            if (isLoggedIn) {
              _goFlightSearch(email);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please login to search flights')),
              );
              Navigator.of(context).pushNamed('/login');
            }
          } else if (index == 2) {
            // Explore
            Navigator.of(context).pushNamed('/explore');
          } else if (index == 3) {
            // Help
            Navigator.of(context).pushNamed('/help');
          } else if (index == 4) {
            // Account
            if (isLoggedIn) {
              _showAccountMenu(context, email);
            } else {
              Navigator.of(context).pushNamed('/login');
            }
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  void _showAccountMenu(BuildContext context, String? email) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(email ?? 'Guest'),
              subtitle: _userFullName != null ? Text(_userFullName!) : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await AuthService.instance.logout();
                if (mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
