import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../db/reservation_db.dart';
import '../services/promo_service.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({super.key});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  Set<String> _selectedSeats = {};
  String _selectedClass = 'Economy';
  Set<String> _occupiedSeats = {};
  bool _loadingSeats = true;
  int _numberOfSeats = 1;
  String? _activePromo;
  bool _isBogoPromo = false;
  
  // Seat configuration: rows 1-3 First Class, 4-8 Business, 9-25 Economy
  final Map<String, List<String>> _seats = {
    'First Class': List.generate(3, (row) => '${row + 1}')
        .expand((row) => ['A', 'B', 'C', 'D'].map((col) => '$row$col'))
        .toList(),
    'Business': List.generate(5, (row) => '${row + 4}')
        .expand((row) => ['A', 'B', 'C', 'D', 'E', 'F'].map((col) => '$row$col'))
        .toList(),
    'Economy': List.generate(17, (row) => '${row + 9}')
        .expand((row) => ['A', 'B', 'C', 'D', 'E', 'F'].map((col) => '$row$col'))
        .toList(),
  };

  final Map<String, double> _classPrices = {
    'First Class': 15000.0,
    'Business': 8000.0,
    'Economy': 3500.0,
  };

  @override
  void initState() {
    super.initState();
    // Load occupied seats after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final promo = await PromoService.instance.getActivePromo();
      setState(() {
        _numberOfSeats = args['numberOfSeats'] as int? ?? 1;
        _selectedClass = args['selectedClass'] as String? ?? 'Economy';
        _activePromo = promo;
        _isBogoPromo = promo == PromoService.promoBogo;
      });
      _loadOccupiedSeats();
    });
  }

  Future<void> _loadOccupiedSeats() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Flight flight = args['flight'] as Flight;
    
    try {
      // Get all reservations from database
      final allReservations = await ReservationDatabase.instance.all();
      
      // Filter reservations for this specific flight and extract seat numbers
      final occupiedSeats = allReservations
          .where((reservation) =>
              reservation.flightNumber == flight.flightNumber &&
              reservation.departureTime == flight.departureTime &&
              reservation.seatNumber != null)
          .map((reservation) => reservation.seatNumber!)
          .toSet();
      
      if (mounted) {
        setState(() {
          _occupiedSeats = occupiedSeats;
          _loadingSeats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSeats = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading seats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Flight flight = args['flight'] as Flight;
    final String userEmail = args['userEmail'] as String;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Seat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Flight Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${flight.departureAirport} → ${flight.arrivalAirport}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flight ${flight.flightNumber} • ${flight.airline}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Class',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _classPrices.keys.map((className) {
                    final isSelected = _selectedClass == className;
                    return FilterChip(
                      label: Text('$className\n₱${_classPrices[className]!.toStringAsFixed(0)}'),
                      selected: isSelected,
                      onSelected: null, // Disabled - class is pre-selected
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                      backgroundColor: isSelected ? null : Colors.grey[200],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Available', Colors.green[100]!),
                _buildLegendItem('Selected', Theme.of(context).colorScheme.primary),
                _buildLegendItem('Occupied', Colors.grey[300]!),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Seat Map
          Expanded(
            child: _loadingSeats
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading available seats...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
                    child: Column(
                      children: [
                        // Cockpit indicator
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.airlines, size: 32),
                          ),
                        ),
                        
                        _buildSeatGrid(isSmallScreen),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
          
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedSeats.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isBogoPromo 
                                  ? '${_selectedSeats.length} of ${_numberOfSeats * 2} seat(s)'
                                  : '${_selectedSeats.length} of $_numberOfSeats seat(s)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Seats: ${_selectedSeats.join(", ")}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _selectedClass,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (_isBogoPromo)
                              Text(
                                'BOGO: Pay for ${_selectedSeats.length ~/ 2}, get ${_selectedSeats.length ~/ 2} FREE!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Show original price with strikethrough if promo is active
                            if (_activePromo != null) ...[
                              Text(
                                '₱${(_classPrices[_selectedClass]! * _selectedSeats.length).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            Text(
                              () {
                                final basePrice = _classPrices[_selectedClass]!;
                                if (_isBogoPromo) {
                                  // BOGO: Pay for half of selected seats
                                  final seatsToPayFor = _selectedSeats.length ~/ 2;
                                  return '₱${(basePrice * seatsToPayFor).toStringAsFixed(2)}';
                                } else if (_activePromo != null) {
                                  // Other promos: apply discount to actual selected seats
                                  final promoResult = PromoService.instance.applyPromo(
                                    _activePromo, 
                                    basePrice, 
                                    _selectedSeats.length
                                  );
                                  return '₱${promoResult.finalPrice.toStringAsFixed(2)}';
                                } else {
                                  // No promo: pay for all selected seats
                                  return '₱${(basePrice * _selectedSeats.length).toStringAsFixed(2)}';
                                }
                              }(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _activePromo != null ? Colors.green.shade700 : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _selectedSeats.length != (_isBogoPromo ? _numberOfSeats * 2 : _numberOfSeats)
                          ? null
                          : () {
                              final promoResult = PromoService.instance.applyPromo(
                                _activePromo,
                                _classPrices[_selectedClass]!,
                                _isBogoPromo ? _numberOfSeats : _selectedSeats.length,
                              );
                              Navigator.of(context).pushNamed(
                                '/payment',
                                arguments: {
                                  'flight': flight,
                                  'userEmail': userEmail,
                                  'seatNumber': _selectedSeats.join(', '),
                                  'seatClass': _selectedClass,
                                  'price': promoResult.finalPrice,
                                  'promoCode': _activePromo,
                                  'numberOfSeats': _selectedSeats.length,
                                },
                              );
                            },
                      child: Text(
                        _selectedSeats.length != (_isBogoPromo ? _numberOfSeats * 2 : _numberOfSeats)
                            ? 'Select ${(_isBogoPromo ? _numberOfSeats * 2 : _numberOfSeats) - _selectedSeats.length} more seat(s)'
                            : _isBogoPromo 
                                ? 'Continue to Payment (Pay for $_numberOfSeats only!)'
                                : 'Continue to Payment',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatGrid(bool isSmallScreen) {
    final seats = _seats[_selectedClass]!;
    final cols = _selectedClass == 'First Class' ? 4 : 6;
    final seatSize = isSmallScreen ? 36.0 : 48.0;
    
    // Group seats by row
    final Map<String, List<String>> seatsByRow = {};
    for (var seat in seats) {
      final row = seat.substring(0, seat.length - 1);
      seatsByRow.putIfAbsent(row, () => []);
      seatsByRow[row]!.add(seat);
    }

    return Column(
      children: seatsByRow.entries.map((entry) {
        final row = entry.key;
        final rowSeats = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row number
              SizedBox(
                width: 30,
                child: Text(
                  row,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              // Seats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left side seats
                    ...rowSeats.sublist(0, cols ~/ 2).map((seat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildSeat(seat, seatSize),
                      );
                    }),
                    // Aisle
                    SizedBox(width: isSmallScreen ? 16 : 24),
                    // Right side seats
                    ...rowSeats.sublist(cols ~/ 2).map((seat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildSeat(seat, seatSize),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeat(String seatNumber, double size) {
    final isOccupied = _occupiedSeats.contains(seatNumber);
    final isSelected = _selectedSeats.contains(seatNumber);
    
    Color backgroundColor;
    Color? borderColor;
    
    if (isOccupied) {
      backgroundColor = Colors.grey[300]!;
      borderColor = Colors.grey[400];
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      borderColor = Theme.of(context).colorScheme.primary;
    } else {
      backgroundColor = Colors.green[100]!;
      borderColor = Colors.grey[400];
    }

    return InkWell(
      onTap: isOccupied
          ? null
          : () {
              setState(() {
                final maxSeats = _isBogoPromo ? _numberOfSeats * 2 : _numberOfSeats;
                if (isSelected) {
                  _selectedSeats.remove(seatNumber);
                } else if (_selectedSeats.length < maxSeats) {
                  _selectedSeats.add(seatNumber);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You can only select $maxSeats seat(s)')),
                  );
                }
              });
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor!),
        ),
        child: Center(
          child: isOccupied
              ? Icon(Icons.close, size: size * 0.5, color: Colors.grey[600])
              : Text(
                  seatNumber.substring(seatNumber.length - 1),
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
