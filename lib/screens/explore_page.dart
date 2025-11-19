import 'package:flutter/material.dart';
import '../services/promo_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, dynamic>> _destinations = const [
    {
      'name': 'Boracay',
      'description': 'White sand beaches and lively nightlife',
      'icon': Icons.beach_access,
    },
    {
      'name': 'Baguio',
      'description': 'Cool mountain air and pine trees',
      'icon': Icons.park,
    },
    {
      'name': 'Cebu',
      'description': 'Historical sites and island hopping',
      'icon': Icons.landscape,
    },
    {
      'name': 'Tokyo',
      'description': 'Vibrant city life and fantastic food',
      'icon': Icons.location_city,
    },
  ];

  final List<Map<String, dynamic>> _promos = const [
    {
      'title': '20% off flights this November!',
      'code': 'NOV20FLY',
      'description':
          '''Is the holiday rush starting too early? Reward yourself with a well-deserved escape! Fly smart this November by taking advantage of our biggest pre-holiday discount. We are offering a massive 20% OFF on the base fare for ALL Domestic and International Flights, giving you the perfect opportunity to beat the Christmas crowd and enjoy popular destinations like Palawan, Boracay, or Tokyo before peak season prices kick in. The world is calling—and it's 20% cheaper! This offer is valid for a limited booking period, so don't wait!

  - 20% OFF on the base fare.
  - Valid for flights taken from November 19, 2025 to November 30, 2025.
  - PROMO CODE: NOV20FLY

Book your blissful getaway today! Limited seats are available, 
so use the code and secure your flight now!''',
    },
    {
      'title': 'Buy 1 Get 1 Seat Sale',
      'code': 'BOGO',
      'description':
          ''' Invite your favorite travel buddy! Our most exciting seat sale is back—because every adventure is better when shared, and now you can travel for half the price! For a very limited time only, when you book one ticket on select routes, you get the second ticket absolutely FREE. That means you pay for one, and your companion flies for zero base fare! This is perfect for couples, best friends, or family members looking to explore together without breaking the bank.

  - Buy One Seat, Get One FREE.
  - Perfect for sharing the travel cost with a companion.
  - Flights to Cebu, Davao, Singapore, and Hong Kong!
  - PROMO CODE: BOGO

This BOGO deal won't last long! Click the link below, search for flights marked with the BOGO icon, and find your FREE seat before they're all gone!
''',
    },
  ];

  final Map<String, String> _tips = const {
    'How to pack light':
        '''🧳 How to Pack Light for Travelling: The Ultimate Carry-On-Only Guide
  
Ditching the heavy, checked luggage is one of the best ways to simplify your trip and save money. Want to glide through the airport and enjoy the freedom of having everything you need in a single carry-on? Here's how you can master the art of packing light:
  
  - 💊 The Capsule Wardrobe Method:
    - Choose a color palette (e.g., neutrals like black, white, and gray, plus one accent color like blue).
    - Pack only items that can be mixed and matched to create at least three different outfits. Think two bottoms, four tops, and one layering piece (jacket or cardigan).

  - 🗞️ Roll, Don't Fold (or Use Cubes!): Rolling your clothes saves space and minimizes wrinkles. Alternatively, invest in compression packing cubes. They are a game-changer for squeezing every bit of air out of your clothes.

  - 👕 The "One-Wear" Rule for Clothes: Unless it's a specialty item (like a coat), ask yourself if you can comfortably wear an item at least twice. If the answer is no, leave it!

  - 🪥 Toiletries: Go Mini or Buy There: Decant all your liquids into travel-sized containers (<100ml) to comply with TSA/airport rules. Better yet, buy heavy items like shampoo and sunblock when you arrive at your destination.

  - 🧥 Wear Your Bulkiest Items: Always wear your bulkiest shoes (boots or sneakers) and heaviest jacket/sweater on the plane. It saves precious space in your bag!
''',
    'Best time to travel to Japan': '''🗾 Chasing Blossoms or Fall Foliage?

Japan is a stunning year-round destination, but the "best" time really depends on what kind of experience you're chasing. Most travelers agree that the Spring and Autumn shoulder seasons offer the most pleasant weather and spectacular scenery.

🌸 Spring (March to May): Cherry Blossom Season
  - Why it's the best: This is the most popular time to visit, centered around the world-famous Sakura (Cherry Blossom) viewing, which typically peaks from late March to mid-April across the main islands.
  - What to expect: Pleasant, mild temperatures, clear skies, and a vibrant, celebratory atmosphere.
  - Note!!!: This is also the most crowded and expensive time. You must book flights and accommodations many months in advance. Pro-Tip: Avoid the first week of May (Golden Week), which is a major Japanese holiday, making travel chaotic.

🍁 Autumn (September to November): Fall Foliage
  - Why you should give it a try: The scenery is equally breathtaking as the maple leaves (Koyo) turn vibrant shades of red, orange, and gold. The temperatures are crisp, cool, and perfect for walking.
  - What to expect: Comfortably cool weather—ideal for sightseeing and hiking. November is generally peak leaf-viewing season in major cities like Kyoto and Tokyo.
  - Heads Up!: Late autumn can still be busy, but generally less hectic than the Spring. September still carries a small risk of typhoons in the south, but October and November are usually lovely.

❄️ Winter (December to February): Skiing and Fewer Crowds
  - What's the vibe: Great for budget-conscious travelers and winter sports enthusiasts. Destinations like Hokkaido are perfect for skiing and snow festivals (like the famous Sapporo Snow Festival in February).
  - Bonus: You get the clearest views of Mount Fuji in the cold, dry air!
''',
  };

  final Set<String> _expandedPromos = <String>{};
  final Set<String> _expandedTips = <String>{};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular Destinations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: isSmallScreen ? 8 : 12),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              mainAxisSpacing: isSmallScreen ? 8 : 12,
              childAspectRatio: isSmallScreen ? 0.85 : 0.75,
              children: _destinations.map((d) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          child: Icon(d['icon'] as IconData,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(d['name'] as String,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Expanded(
                            child: Text(d['description'] as String,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey))),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/flight_search');
                          },
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Promos & Deals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: _promos.map((promo) {
                final title = promo['title'] as String;
                final code = promo['code'] as String;
                final description = promo['description'] as String;
                return Column(
                  children: [
                    ListTile(
                      title: Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            if (_expandedPromos.contains(title)) {
                              _expandedPromos.remove(title);
                            } else {
                              _expandedPromos.add(title);
                            }
                          });
                        },
                        child: Text(
                            _expandedPromos.contains(title) ? 'Close' : 'View'),
                      ),
                      onTap: () {
                        setState(() {
                          if (_expandedPromos.contains(title)) {
                            _expandedPromos.remove(title);
                          } else {
                            _expandedPromos.add(title);
                          }
                        });
                      },
                    ),
                    ClipRect(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _expandedPromos.contains(title)
                            ? SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Card(
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(description),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FilledButton(
                                                onPressed: () async {
                                                  // Activate promo
                                                  await PromoService.instance.activatePromo(code);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Promo "$title" activated! Valid for 24 hours.'),
                                                        backgroundColor: Colors.green,
                                                        duration: const Duration(seconds: 3),
                                                      ),
                                                    );
                                                    Navigator.of(context)
                                                        .pushNamed('/flight_search');
                                                  }
                                                },
                                                child: const Text('Redeem'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Travel Tips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: _tips.entries.map((entry) {
                final key = entry.key;
                final value = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text(key),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            if (_expandedTips.contains(key)) {
                              _expandedTips.remove(key);
                            } else {
                              _expandedTips.add(key);
                            }
                          });
                        },
                        child: Text(
                            _expandedTips.contains(key) ? 'Close' : 'View'),
                      ),
                      onTap: () {
                        setState(() {
                          if (_expandedTips.contains(key)) {
                            _expandedTips.remove(key);
                          } else {
                            _expandedTips.add(key);
                          }
                        });
                      },
                    ),
                    ClipRect(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _expandedTips.contains(key)
                            ? SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(value),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
