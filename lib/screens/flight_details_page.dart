import 'package:flutter/material.dart';
import '../db/reservation_db.dart';

class FlightDetailsPage extends StatelessWidget {
  const FlightDetailsPage({super.key});

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final reservation =
        ModalRoute.of(context)!.settings.arguments as Reservation;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flight to ${reservation.to}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flight Details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (reservation.flightNumber != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.airlines,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            reservation.flightNumber!,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (reservation.airline != null)
                        Text(
                          reservation.airline!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      const Divider(height: 24),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.connecting_airports, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'From: ${reservation.from}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    if (reservation.departureTime != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          'Departure: ${_formatDateTime(reservation.departureTime!)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.flight_land, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To: ${reservation.to}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    if (reservation.arrivalTime != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          'Arrival: ${_formatDateTime(reservation.arrivalTime!)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    if (reservation.seatNumber != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.event_seat, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Seat: ${reservation.seatNumber}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (reservation.seatClass != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Text(
                                reservation.seatClass!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (reservation.price != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Price: ₱${reservation.price!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (reservation.isPaid == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text(
                                'PAID',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Booked on: ${_formatDate(reservation.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (reservation.status != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              reservation.status!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final shouldCancel = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Cancellation'),
                        content: const Text(
                            'Are you sure you want to cancel this flight?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (shouldCancel == true) {
                      await ReservationDatabase.instance
                          .delete(reservation.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Flight cancelled successfully'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        // Pop back with true to indicate cancellation occurred
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Flight'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // No action yet
                  },
                  icon: const Icon(Icons.contact_phone),
                  label: const Text('Contact Flight'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}