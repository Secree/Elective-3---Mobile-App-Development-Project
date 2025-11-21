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
  int _numberOfSeats = 1;
  final Set<String> _selectedSeats = {};
  
  // Seat layout: 6 seats per row (A-F), 20 rows
  static const int _totalRows = 20;
  static const List<String> _seatColumns = ['A', 'B', 'C', 'D', 'E', 'F'];
  final Set<String> _occupiedSeats = {'1A', '1B', '3C', '5D', '7E', '10F', '12A', '15C'}; // Mock occupied seats

  void _toggleSeat(String seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else if (_selectedSeats.length < _numberOfSeats) {
        _selectedSeats.add(seat);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select $_numberOfSeats seat(s)')),
        );
      }
    });
  }

  Future<void> _reserve(String? userEmail) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    if (_selectedSeats.length != _numberOfSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select exactly $_numberOfSeats seat(s)')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final r = Reservation(
        from: _from, 
        to: _to,
        userId: userEmail,
        seatNumber: _selectedSeats.join(', '), // Store multiple seats
      );
      await ReservationDatabase.instance.create(r);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Reserved ${_selectedSeats.length} seat(s): ${_selectedSeats.join(", ")}')));
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
                        // Number of seats selector
                        Row(
                          children: [
                            const Text('Number of seats:', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _numberOfSeats > 1 ? () {
                                setState(() {
                                  _numberOfSeats--;
                                  // Remove excess selected seats
                                  while (_selectedSeats.length > _numberOfSeats) {
                                    _selectedSeats.remove(_selectedSeats.last);
                                  }
                                });
                              } : null,
                            ),
                            Text('$_numberOfSeats', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _numberOfSeats < 6 ? () {
                                setState(() => _numberOfSeats++);
                              } : null,
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        // Seat picker
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text('Select Your Seats', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              // Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend(Colors.grey.shade300, 'Available'),
                                  const SizedBox(width: 12),
                                  _buildLegend(Colors.blue, 'Selected'),
                                  const SizedBox(width: 12),
                                  _buildLegend(Colors.red.shade300, 'Occupied'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Seat grid
                              SizedBox(
                                height: 300,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(_totalRows, (rowIndex) {
                                      final row = rowIndex + 1;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('$row', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            ..._seatColumns.map((col) {
                                              final seatId = '$row$col';
                                              final isOccupied = _occupiedSeats.contains(seatId);
                                              final isSelected = _selectedSeats.contains(seatId);
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                                child: GestureDetector(
                                                  onTap: isOccupied ? null : () => _toggleSeat(seatId),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: isOccupied 
                                                          ? Colors.red.shade300 
                                                          : isSelected 
                                                              ? Colors.blue 
                                                              : Colors.grey.shade300,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        col,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isSelected || isOccupied ? Colors.white : Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              if (_selectedSeats.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Selected: ${_selectedSeats.join(", ")}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ],
                          ),
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

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
