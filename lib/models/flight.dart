class Flight {
  final String flightNumber;
  final String airline;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String status;
  final String? terminal;
  final String? gate;

  Flight({
    required this.flightNumber,
    required this.airline,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    this.terminal,
    this.gate,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNumber: json['flight']['iata'] ?? json['flight']['number'] ?? 'N/A',
      airline: json['airline']['name'] ?? 'Unknown Airline',
      departureAirport: json['departure']['airport'] ?? 'Unknown',
      arrivalAirport: json['arrival']['airport'] ?? 'Unknown',
      departureTime: json['departure']['scheduled'] ?? json['departure']['estimated'] ?? 'N/A',
      arrivalTime: json['arrival']['scheduled'] ?? json['arrival']['estimated'] ?? 'N/A',
      status: json['flight_status'] ?? 'unknown',
      terminal: json['departure']['terminal'],
      gate: json['departure']['gate'],
    );
  }

  // For demo/mock data
  factory Flight.mock({
    required String flightNumber,
    required String airline,
    required String from,
    required String to,
    required String departureTime,
    required String arrivalTime,
    String status = 'scheduled',
  }) {
    return Flight(
      flightNumber: flightNumber,
      airline: airline,
      departureAirport: from,
      arrivalAirport: to,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      status: status,
    );
  }
}
