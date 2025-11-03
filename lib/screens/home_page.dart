import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in from AuthService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
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
    await Navigator.of(context).pushNamed('/flight_search', arguments: userEmail);
    // Refresh reservations when returning
    await _load(userEmail);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email =
        ModalRoute.of(context)!.settings.arguments as String?;
    final isLoggedIn = email != null;
    
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
      appBar: AppBar(
        automaticallyImplyLeading: false, // disables the back button
        title: const Text('Philippine Airlines'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Menu items: Book, Explore, Help
          TextButton(
            onPressed: isLoggedIn 
                ? () => _goFlightSearch(email) 
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to search flights'),
                      ),
                    );
                    Navigator.of(context).pushNamed('/login');
                  },
            child: const Text('Book', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/explore');
            },
            child: const Text('Explore', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/help');
            },
            child: const Text('Help', style: TextStyle(color: Colors.white)),
          ),
          // Divider
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          // Login/Signup or User menu
          if (isLoggedIn) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              onSelected: (v) async {
                if (v == 'logout') {
                  await AuthService.instance.logout();
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              },
              itemBuilder: (c) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text('Logged in as: $email'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 4),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/signup');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/image/bg-airplane.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: Column(
                      children: [
                        // Main Headline
                        Text(
                          isLoggedIn
                              ? (_userFullName != null
                                  ? 'Welcome Back, $_userFullName'
                                  : 'Welcome Back')
                              : 'Fly with Philippine Airlines',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Subheadline
                        Text(
                          isLoggedIn
                              ? 'Your next adventure awaits'
                              : 'Experience world-class service and comfort',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Search/Book Flight Card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flight_takeoff,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Travel Freely in the Skies',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.search, size: 24),
                                    label: const Text(
                                      'Book Flights',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: isLoggedIn 
                                        ? () => _goFlightSearch(email) 
                                        : () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please login to search flights'),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                            Navigator.of(context).pushNamed('/login');
                                          },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 32,
                                      ),
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  if (!isLoggedIn) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Login or sign up to unlock exclusive deals',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Features Section
                  if (!isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Why Choose Us',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  context,
                                  Icons.verified_user,
                                  'Safe & Secure',
                                  'Your safety is our priority',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFeatureCard(
                                  context,
                                  Icons.local_offer,
                                  'Best Prices',
                                  'Competitive fares guaranteed',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFeatureCard(
                                  context,
                                  Icons.support_agent,
                                  '24/7 Support',
                                  'We\'re here to help',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (isLoggedIn) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Ongoing Reservations',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _reservations.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.flight_outlined,
                                        size: 64,
                                        color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No reservations yet',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Book your first flight to get started',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: _reservations.map((r) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.flight,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    title: Text(
                                      '${r.from} → ${r.to}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (r.flightNumber != null && r.airline != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${r.airline} • ${r.flightNumber}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          'Booked: ${_formatDate(r.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.of(context).pushNamed(
                                        '/flight_details',
                                        arguments: r,
                                      );
                                      // Reload reservations if flight was cancelled
                                      if (result == true) {
                                        await _load(email);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.airplane_ticket, 
                                  size: 100, 
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'Book Your Flight Today',
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Discover amazing destinations and create unforgettable memories.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/login');
                                },
                                child: const Text('Get Started'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
