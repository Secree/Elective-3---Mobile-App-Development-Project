import 'package:flutter/material.dart';
import '../db/reservation_db.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ReservationDatabase.instance.all();
    setState(() => _reservations = list);
  }

  Future<void> _goReserve() async {
    final res = await Navigator.of(context).pushNamed('/reserve');
    // If reservation succeeded, refresh list
    if (res == true) await _load();
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
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Philippine Airlines'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Menu items: Book, Explore, Help
          TextButton(
            onPressed: isLoggedIn 
                ? _goReserve 
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to book flights'),
                      ),
                    );
                    Navigator.of(context).pushNamed('/login');
                  },
            child: const Text('Book', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Explore - Coming Soon!')),
              );
            },
            child: const Text('Explore', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help - Coming Soon!')),
              );
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
              onSelected: (v) {
                if (v == 'logout') {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
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
                              ? 'Welcome Back, ${email.split('@')[0]}'
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
                                        'Book Your Flight',
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
                                      'Search Flights',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: isLoggedIn 
                                        ? _goReserve 
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
                                  child: ListTile(
                                    leading: const Icon(Icons.flight),
                                    title: Text('${r.from} → ${r.to}'),
                                    subtitle: Text(r.createdAt.toLocal().toString()),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        '/flight_details',
                                        arguments: r,
                                      );
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
