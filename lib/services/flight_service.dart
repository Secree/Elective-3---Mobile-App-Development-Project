import '../models/flight.dart';

class FlightService {
  // Using AviationStack API - Free tier available
  // Sign up at: https://aviationstack.com/
  // For now, using mock data since API key is required
  // Uncomment these when using the real API:
   static const String _baseUrl = 'http://api.aviationstack.com/v1';
   static const String _apiKey = 'f0f92453f4cfc3dab2d016c6d7ac30aa'; // Replace with your API key

  // Philippine airports IATA codes
  static const Map<String, String> philippineAirports = {
    'MNL': 'Ninoy Aquino International Airport (Manila)',
    'CEB': 'Mactan-Cebu International Airport (Cebu)',
    'DVO': 'Francisco Bangoy International Airport (Davao)',
    'ILO': 'Iloilo International Airport (Iloilo)',
    'CRK': 'Clark International Airport (Pampanga)',
    'KLO': 'Kalibo International Airport (Kalibo)',
    'BCD': 'Bacolod-Silay Airport (Bacolod)',
    'TAC': 'Daniel Z. Romualdez Airport (Tacloban)',
    'PPS': 'Puerto Princesa International Airport (Palawan)',
    'TAG': 'Tagbilaran Airport (Bohol)',
  };

  static Future<List<Flight>> searchFlights({
    String? from,
    String? to,
  }) async {
    // For demo purposes, return mock data
    // In production, uncomment the API call below
    return _getMockFlights(from: from, to: to);

    /* Uncomment this when you have an API key:
    try {
      final params = {
        'access_key': _apiKey,
        if (from != null && from.isNotEmpty) 'dep_iata': from,
        if (to != null && to.isNotEmpty) 'arr_iata': to,
        'limit': '20',
      };

      final uri = Uri.parse(_baseUrl + '/flights').replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List flightsJson = data['data'] ?? [];
        return flightsJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load flights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching flights: $e');
      // Fallback to mock data
      return _getMockFlights(from: from, to: to);
    }
    */
  }

  static List<Flight> _getMockFlights({String? from, String? to}) {
    final now = DateTime.now();
    final List<Flight> allFlights = [
      // Manila flights
      Flight.mock(
        flightNumber: 'PR501',
        airline: 'Philippine Airlines',
        from: 'MNL - Manila',
        to: 'CEB - Cebu',
        departureTime: now.add(const Duration(hours: 2)).toString(),
        arrivalTime: now.add(const Duration(hours: 3, minutes: 30)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: 'PR302',
        airline: 'Philippine Airlines',
        from: 'MNL - Manila',
        to: 'DVO - Davao',
        departureTime: now.add(const Duration(hours: 3)).toString(),
        arrivalTime: now.add(const Duration(hours: 5)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: '5J123',
        airline: 'Cebu Pacific',
        from: 'MNL - Manila',
        to: 'ILO - Iloilo',
        departureTime: now.add(const Duration(hours: 4)).toString(),
        arrivalTime: now.add(const Duration(hours: 5, minutes: 15)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: 'Z2456',
        airline: 'AirAsia Philippines',
        from: 'MNL - Manila',
        to: 'KLO - Kalibo',
        departureTime: now.add(const Duration(hours: 5)).toString(),
        arrivalTime: now.add(const Duration(hours: 6)).toString(),
        status: 'scheduled',
      ),
      // Cebu flights
      Flight.mock(
        flightNumber: 'PR502',
        airline: 'Philippine Airlines',
        from: 'CEB - Cebu',
        to: 'MNL - Manila',
        departureTime: now.add(const Duration(hours: 2, minutes: 30)).toString(),
        arrivalTime: now.add(const Duration(hours: 4)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: '5J789',
        airline: 'Cebu Pacific',
        from: 'CEB - Cebu',
        to: 'DVO - Davao',
        departureTime: now.add(const Duration(hours: 3, minutes: 15)).toString(),
        arrivalTime: now.add(const Duration(hours: 4, minutes: 30)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: 'DG456',
        airline: 'Cebgo',
        from: 'CEB - Cebu',
        to: 'TAG - Bohol',
        departureTime: now.add(const Duration(hours: 1, minutes: 45)).toString(),
        arrivalTime: now.add(const Duration(hours: 2, minutes: 30)).toString(),
        status: 'scheduled',
      ),
      // Davao flights
      Flight.mock(
        flightNumber: 'PR303',
        airline: 'Philippine Airlines',
        from: 'DVO - Davao',
        to: 'MNL - Manila',
        departureTime: now.add(const Duration(hours: 6)).toString(),
        arrivalTime: now.add(const Duration(hours: 8)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: '5J234',
        airline: 'Cebu Pacific',
        from: 'DVO - Davao',
        to: 'CEB - Cebu',
        departureTime: now.add(const Duration(hours: 4, minutes: 30)).toString(),
        arrivalTime: now.add(const Duration(hours: 5, minutes: 45)).toString(),
        status: 'scheduled',
      ),
      // Clark flights
      Flight.mock(
        flightNumber: 'PR567',
        airline: 'Philippine Airlines',
        from: 'CRK - Clark',
        to: 'BCD - Bacolod',
        departureTime: now.add(const Duration(hours: 3, minutes: 30)).toString(),
        arrivalTime: now.add(const Duration(hours: 4, minutes: 45)).toString(),
        status: 'scheduled',
      ),
      Flight.mock(
        flightNumber: 'Z2789',
        airline: 'AirAsia Philippines',
        from: 'CRK - Clark',
        to: 'PPS - Palawan',
        departureTime: now.add(const Duration(hours: 5, minutes: 15)).toString(),
        arrivalTime: now.add(const Duration(hours: 6, minutes: 30)).toString(),
        status: 'scheduled',
      ),
      // Palawan flights
      Flight.mock(
        flightNumber: 'PR890',
        airline: 'Philippine Airlines',
        from: 'PPS - Palawan',
        to: 'MNL - Manila',
        departureTime: now.add(const Duration(hours: 7)).toString(),
        arrivalTime: now.add(const Duration(hours: 8, minutes: 30)).toString(),
        status: 'scheduled',
      ),
    ];

    // Filter flights based on search criteria
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return allFlights.where((flight) {
        final matchesFrom = flight.departureAirport.toLowerCase().contains(from.toLowerCase());
        final matchesTo = flight.arrivalAirport.toLowerCase().contains(to.toLowerCase());
        return matchesFrom && matchesTo;
      }).toList();
    } else if (from != null && from.isNotEmpty) {
      return allFlights.where((flight) =>
          flight.departureAirport.toLowerCase().contains(from.toLowerCase())).toList();
    } else if (to != null && to.isNotEmpty) {
      return allFlights.where((flight) =>
          flight.arrivalAirport.toLowerCase().contains(to.toLowerCase())).toList();
    }

    return allFlights;
  }
}
