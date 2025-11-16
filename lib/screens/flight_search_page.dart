import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  List<Flight> _flights = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Load all flights on init
    _searchFlights();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _searchFlights() async {
    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    try {
      final flights = await FlightService.searchFlights(
        from: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
        to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
      );

      setState(() {
        _flights = flights;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flights: $e')),
        );
      }
    }
  }

  void _clearSearch() {
    _fromController.clear();
    _toController.clear();
    _searchFlights();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (e) {
      return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.green;
      case 'active':
      case 'en-route':
        return Colors.blue;
      case 'landed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'delayed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the user email from route arguments
    final userEmail = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Flights'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search Form
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height < 600 ? 12 : 16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          labelText: 'From',
                          hintText: 'e.g., MNL, Manila',
                          prefixIcon: const Icon(Icons.flight_takeoff),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          labelText: 'To',
                          hintText: 'e.g., CEB, Cebu',
                          prefixIcon: const Icon(Icons.flight_land),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _searchFlights,
                        icon: const Icon(Icons.search),
                        label: const Text('Search Flights'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Common airports: MNL (Manila), CEB (Cebu), DVO (Davao), CRK (Clark)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _flights.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.connecting_airports,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _hasSearched
                                  ? 'No flights found'
                                  : 'Search for flights',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hasSearched
                                  ? 'Try different search criteria'
                                  : 'Enter departure and arrival locations',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _flights.length,
                        itemBuilder: (context, index) {
                          final flight = _flights[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _showFlightDetails(flight, userEmail);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Airline and Flight Number
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            flight.flightNumber,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            flight.airline,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(flight.status)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _getStatusColor(flight.status),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            flight.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(flight.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Flight Route
                                    Row(
                                      children: [
                                        // Departure
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _formatDateTime(flight.departureTime),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                flight.departureAirport,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _formatDate(flight.departureTime),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Arrow
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Direct',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Arrival
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _formatDateTime(flight.arrivalTime),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                flight.arrivalAirport,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.end,
                                              ),
                                              Text(
                                                _formatDate(flight.arrivalTime),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFlightDetails(Flight flight, String? userEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _FlightDetailsSheet(
          flight: flight,
          scrollController: scrollController,
          userEmail: userEmail,
        ),
      ),
    );
  }
}

// Stateful widget for flight details to handle booking
class _FlightDetailsSheet extends StatefulWidget {
  final Flight flight;
  final ScrollController scrollController;
  final String? userEmail;

  const _FlightDetailsSheet({
    required this.flight,
    required this.scrollController,
    this.userEmail,
  });

  @override
  State<_FlightDetailsSheet> createState() => _FlightDetailsSheetState();
}

class _FlightDetailsSheetState extends State<_FlightDetailsSheet> {
  bool _isBooking = false;

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _bookFlight() async {
    if (widget.userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book flights')),
      );
      return;
    }

    // Close the bottom sheet first
    Navigator.pop(context);
    
    // Navigate to seat selection
    Navigator.of(context).pushNamed(
      '/seat_selection',
      arguments: {
        'flight': widget.flight,
        'userEmail': widget.userEmail,
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Flight Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Flight Number', widget.flight.flightNumber),
            _buildDetailRow('Airline', widget.flight.airline),
            const Divider(height: 32),
            _buildDetailRow('Departure', widget.flight.departureAirport),
            _buildDetailRow('Departure Time', _formatDateTime(widget.flight.departureTime)),
            if (widget.flight.terminal != null)
              _buildDetailRow('Terminal', widget.flight.terminal!),
            if (widget.flight.gate != null) 
              _buildDetailRow('Gate', widget.flight.gate!),
            const Divider(height: 32),
            _buildDetailRow('Arrival', widget.flight.arrivalAirport),
            _buildDetailRow('Arrival Time', _formatDateTime(widget.flight.arrivalTime)),
            const Divider(height: 32),
            _buildDetailRow('Status', widget.flight.status.toUpperCase()),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isBooking ? null : _bookFlight,
              icon: _isBooking 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.bookmark_add),
              label: Text(_isBooking ? 'Booking...' : 'Book This Flight'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
