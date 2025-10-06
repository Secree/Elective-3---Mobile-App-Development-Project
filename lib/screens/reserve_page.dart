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

  void _reserve() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final r = Reservation(from: _from, to: _to);
    ReservationDatabase.instance.create(r).then((saved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserved flight from ${saved.from} to ${saved.to}')));
      Navigator.of(context).pop(true);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reserve flight')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve Flight')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'From (city/airport)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter origin' : null,
                onSaved: (v) => _from = v!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'To (city/airport)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter destination' : null,
                onSaved: (v) => _to = v!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _reserve, child: const Text('Reserve'))
            ],
          ),
        ),
      ),
    );
  }
}
