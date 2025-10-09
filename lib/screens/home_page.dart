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

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String? ?? 'user';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reserve') _goReserve();
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'reserve', child: Text('Reserve Flight')),
            ],
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'lib/image/bg-airplane.jpg',
            fit: BoxFit.cover,
          ),
          // A dark overlay to improve text readability
          Container(color: const Color.fromRGBO(0, 0, 0, 0.35)),
          // Foreground content with padding
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.flight_takeoff, size: 72, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome, $email', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Find and reserve flights quickly.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Search Flights'),
                  onPressed: _goReserve,
                ),
                const SizedBox(height: 20),
                const Text('Ongoing Reservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: _reservations.isEmpty
                      ? const Center(child: Text('No reservations yet'))
                      : ListView.builder(
                          itemCount: _reservations.length,
                          itemBuilder: (c, i) {
                            final r = _reservations[i];
                            return ListTile(
                              leading: const Icon(Icons.flight),
                              title: Text('${r.from} → ${r.to}'),
                              subtitle: Text(r.createdAt.toLocal().toString()),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
