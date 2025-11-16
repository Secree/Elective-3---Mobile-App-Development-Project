import 'package:flutter/material.dart';
import '../db/reservation_db.dart';

class ReservePage extends StatefulWidget {
  const ReservePage({super.key});

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  final _formKey = GlobalKey<FormState>();
  String _from = '';
  String _to = '';
  bool _loading = false;

  Future<void> _reserve(String? userEmail) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      final r = Reservation(
        from: _from, 
        to: _to,
        userId: userEmail, // Associate with the logged-in user
      );
      final saved = await ReservationDatabase.instance.create(r);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Reserved flight from ${saved.from} to ${saved.to}')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reserve flight')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the user email from route arguments
    final userEmail = ModalRoute.of(context)?.settings.arguments as String?;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reserve Flight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/image/bg-airplane.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Reserve a Flight',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: isSmallScreen ? 20 : null,
                            )),
                        SizedBox(height: isSmallScreen ? 12 : 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'From (city/airport)',
                        prefixIcon: Icon(Icons.connecting_airports),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter origin' : null,
                      onSaved: (v) => _from = v!.trim(),
                    ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'To (city/airport)',
                            prefixIcon: Icon(Icons.flight_land),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter destination'
                              : null,
                          onSaved: (v) => _to = v!.trim(),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 20),
                        _loading
                            ? const CircularProgressIndicator()
                            : FilledButton(
                                onPressed: () => _reserve(userEmail),
                                child: const Text('Reserve'),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
