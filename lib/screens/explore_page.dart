import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

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

  final List<String> _promos = const [
    '20% off flights this November!',
    'Buy 1 Get 1 Seat Sale',
  ];

  final List<String> _tips = const [
    'How to pack light',
    'Best time to travel to Japan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular Destinations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _destinations.map((d) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(d['icon'] as IconData, size: 30, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(d['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Expanded(child: Text(d['description'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey))),
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
            const Text('Promos & Deals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: _promos.map((p) {
                return Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  child: ListTile(
                    title: Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Showing promo: $p')));
                      },
                      child: const Text('View'),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Travel Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: _tips.map((t) {
                return ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(t),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
                  },
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
