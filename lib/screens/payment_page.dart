import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flight.dart';
import '../db/reservation_db.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  
  String _selectedPaymentMethod = 'Credit Card';
  bool _loading = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment(Map<String, dynamic> args) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      final Flight flight = args['flight'] as Flight;
      final String userEmail = args['userEmail'] as String;
      final String seatNumber = args['seatNumber'] as String;
      final String seatClass = args['seatClass'] as String;
      final double price = args['price'] as double;

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create reservation with seat and payment info
      final reservation = Reservation(
        from: flight.departureAirport,
        to: flight.arrivalAirport,
        userId: userEmail,
        flightNumber: flight.flightNumber,
        airline: flight.airline,
        departureTime: flight.departureTime,
        arrivalTime: flight.arrivalTime,
        status: 'confirmed',
        seatNumber: seatNumber,
        seatClass: seatClass,
        price: price,
        isPaid: true,
      );

      await ReservationDatabase.instance.create(reservation);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            title: const Text('Payment Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your seat $seatNumber has been reserved.'),
                const SizedBox(height: 8),
                Text('Flight: ${flight.flightNumber}'),
                Text('Class: $seatClass'),
                Text('Amount Paid: ₱${price.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  // Pop dialog, then pop payment page, then pop seat selection
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Flight flight = args['flight'] as Flight;
    final String seatNumber = args['seatNumber'] as String;
    final String seatClass = args['seatClass'] as String;
    final double price = args['price'] as double;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow('Flight', flight.flightNumber),
                    _buildSummaryRow('Route', '${flight.departureAirport} → ${flight.arrivalAirport}'),
                    _buildSummaryRow('Airline', flight.airline),
                    _buildSummaryRow('Seat', '$seatNumber ($seatClass)'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Method Selection
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPaymentMethodChip('Credit Card', Icons.credit_card),
                _buildPaymentMethodChip('Debit Card', Icons.payment),
                _buildPaymentMethodChip('GCash', Icons.account_balance_wallet),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPaymentMethod == 'GCash') ...[
                    TextFormField(
                      controller: _cardNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'GCash Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        hintText: '09XX XXX XXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter GCash number';
                        if (v.length != 11) return 'Invalid GCash number';
                        return null;
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _cardNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                        hintText: '1234 5678 9012 3456',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter card number';
                        final digits = v.replaceAll(' ', '');
                        if (digits.length < 13) return 'Invalid card number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardHolderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Card Holder Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: 'JOHN DELA CRUZ',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter card holder name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                              hintText: 'MM/YY',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateInputFormatter(),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter expiry';
                              if (!v.contains('/')) return 'Invalid format';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvCtrl,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                              hintText: '123',
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter CVV';
                              if (v.length < 3) return 'Invalid CVV';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : () => _processPayment(args),
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.payment),
                      label: Text(
                        _loading ? 'Processing...' : 'Pay ₱${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secure and encrypted',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChip(String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(method),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPaymentMethod = method;
            // Clear form when switching methods
            _cardNumberCtrl.clear();
            _cardHolderCtrl.clear();
            _expiryCtrl.clear();
            _cvvCtrl.clear();
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}

// Input formatters
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    return newValue;
  }
}
