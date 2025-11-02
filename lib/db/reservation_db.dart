import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String? id;
  final String from;
  final String to;
  final DateTime createdAt;
  final String? flightNumber;
  final String? airline;
  final String? departureTime;
  final String? arrivalTime;
  final String? status;
  final String? userId; // Add user association

  Reservation({
    this.id,
    required this.from,
    required this.to,
    DateTime? createdAt,
    this.flightNumber,
    this.airline,
    this.departureTime,
    this.arrivalTime,
    this.status,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'origin': from,
        'destination': to,
        'createdAt': createdAt.toIso8601String(),
        if (flightNumber != null) 'flightNumber': flightNumber,
        if (airline != null) 'airline': airline,
        if (departureTime != null) 'departureTime': departureTime,
        if (arrivalTime != null) 'arrivalTime': arrivalTime,
        if (status != null) 'status': status,
        if (userId != null) 'userId': userId,
      };

  @override
  String toString() =>
      'Reservation{id: $id, from: $from, to: $to, flight: $flightNumber, at: $createdAt}';

  static Reservation fromMap(Map<String, dynamic> m, String documentId) =>
      Reservation(
        id: documentId,
        from: m['origin'] as String,
        to: m['destination'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        flightNumber: m['flightNumber'] as String?,
        airline: m['airline'] as String?,
        departureTime: m['departureTime'] as String?,
        arrivalTime: m['arrivalTime'] as String?,
        status: m['status'] as String?,
        userId: m['userId'] as String?,
      );

  Reservation copyWith({
    String? id,
    String? from,
    String? to,
    DateTime? createdAt,
    String? flightNumber,
    String? airline,
    String? departureTime,
    String? arrivalTime,
    String? status,
    String? userId,
  }) {
    return Reservation(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      createdAt: createdAt ?? this.createdAt,
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}

class ReservationDatabase {
  static final ReservationDatabase instance = ReservationDatabase._init();
  ReservationDatabase._init();

  final CollectionReference _reservationsCollection =
      FirebaseFirestore.instance.collection('reservations');

  Future<Reservation> create(Reservation r) async {
    try {
      final docRef = await _reservationsCollection.add(r.toMap());
      return r.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error creating reservation: $e');
    }
  }

  Future<List<Reservation>> all() async {
    try {
      final querySnapshot =
          await _reservationsCollection.orderBy('createdAt', descending: true).get();
      return querySnapshot.docs
          .map((doc) =>
              Reservation.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error getting reservations: $e');
    }
  }

  /// Get reservations for a specific user
  Future<List<Reservation>> getByUserId(String userId) async {
    try {
      final querySnapshot = await _reservationsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final reservations = querySnapshot.docs
          .map((doc) =>
              Reservation.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Sort by creation date (newest first)
      reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reservations;
    } catch (e) {
      throw Exception('Error getting user reservations: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _reservationsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting reservation: $e');
    }
  }

  Future<void> close() async {
    // Firestore doesn't require explicit closing
  }
}
