import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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


  final Map<String, String> _policies = const {
    'Refund policy': '''Refunds are processed according to the fare rules of your ticket:

• Non-refundable fares: No refund on the base fare, but taxes and fees may be refunded.
• Refundable fares: Full or partial refund available based on cancellation timing.
• Processing time: Refunds typically take 7-14 business days to reflect in your account.
• Cancellation fees may apply depending on fare type and route.

For refund requests, contact our support team with your booking reference.''',
    'Travel requirements': '''Essential travel requirements you need to know:

• Valid passport with at least 6 months validity from travel date.
• Visa requirements vary by destination - check with the embassy or consulate.
• COVID-19 protocols: Check destination requirements for vaccination certificates or test results.
• Travel insurance is recommended for international flights.
• Minors traveling alone require special documentation and airline approval.

Always verify entry requirements for your destination before travel.''',
    'Check-in guide': '''Make your check-in process smooth and easy:

Online Check-in:
• Available 24 hours before departure
• Access via website or mobile app
• Print boarding pass or save to mobile device

Airport Check-in:
• Arrive 2 hours early for domestic flights
• Arrive 3 hours early for international flights
• Bring valid ID and booking reference
• Check baggage allowance before arrival

Self-service kiosks available at major airports.''',
  };

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
            ExpansionTile(
              title: const Text('Email us'),
              leading: const Icon(Icons.email),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Contact our support team at support@philippineairlines.com\nWe typically respond within 24 hours.'),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Call hotline'),
              leading: const Icon(Icons.call),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Philippines: (+63) 2-8855-8888\nInternational: +1-800-435-9725\nAvailable 24/7'),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Send feedback'),
              leading: const Icon(Icons.feedback),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('We value your feedback! Share your experience, suggestions, or concerns.\nYour input helps us improve our service.'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Policies & Guides', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._policies.entries.map((entry) => ExpansionTile(
                  title: Text(entry.key),
                  leading: const Icon(Icons.info_outline),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(entry.value),
                    ),
                  ],
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
