import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialSlide> _slides = [
    TutorialSlide(
      title: 'Welcome to Flight Reserve',
      description: 'Book flights easily and explore destinations worldwide',
      icon: Icons.airlines,
      color: Colors.blue,
    ),
    TutorialSlide(
      title: 'Search & Compare',
      description: 'Find the best flights with our smart search and filter options',
      icon: Icons.search,
      color: Colors.orange,
    ),
    TutorialSlide(
      title: 'Easy Reservations',
      description: 'Book your flights in just a few taps with secure payment',
      icon: Icons.event_seat,
      color: Colors.green,
    ),
    TutorialSlide(
      title: 'Track Your Trips',
      description: 'Manage all your bookings in one place and get real-time updates',
      icon: Icons.airplane_ticket,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipTutorial,
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index], isSmallScreen);
                },
              ),
            ),
            // Page indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8.0 : 16.0),
              child: _buildPageIndicator(),
            ),
            // Next/Get Started button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 32,
                vertical: isSmallScreen ? 8 : 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 44 : 50,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(TutorialSlide slide, bool isSmallScreen) {
    final iconSize = isSmallScreen ? 100.0 : 150.0;
    final iconInnerSize = isSmallScreen ? 50.0 : 80.0;
    final verticalSpacing = isSmallScreen ? 20.0 : 40.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isSmallScreen ? 16.0 : 32.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: slide.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: iconInnerSize,
                color: slide.color,
              ),
            ),
            SizedBox(height: verticalSpacing),
            // Title
            Text(
              slide.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 20 : 24,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            // Description
            Text(
              slide.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
