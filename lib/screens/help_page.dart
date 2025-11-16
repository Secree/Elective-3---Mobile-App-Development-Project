import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I cancel a booking?',
      'a': 'Open the reservation details and tap Cancel. Refunds depend on fare rules.',
    },
    {
      'q': 'What is the baggage limit?',
      'a': 'Baggage allowance varies by fare and route. Check the flight details for allowance.',
    },
    {
      'q': 'How do I pay for my flight?',
      'a': 'We accept credit cards and selected payment partners. Payment is completed at checkout.',
    },
  ];

  final List<Map<String, String>> _policies = const [
    {'title': 'Refund policy', 'desc': 'Learn how refunds are handled.'},
    {'title': 'Travel requirements', 'desc': 'Visa, passport and entry rules.'},
    {'title': 'Check-in guide', 'desc': 'How to check-in online and at the airport.'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._faqs.map((f) => ExpansionTile(
                  title: Text(f['q']!),
                  children: [Padding(padding: const EdgeInsets.all(12), child: Text(f['a']!))],
                )),
            const SizedBox(height: 16),
            const Text('Contact Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email us'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open email composer')));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.call),
                      title: const Text('Call hotline'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call support')));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text('Send feedback'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open feedback form')));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Policies & Guides', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._policies.map((p) => Card(
                  child: ListTile(
                    title: Text(p['title']!),
                    subtitle: Text(p['desc']!),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open ${p['title']}')));
                    },
                  ),
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
