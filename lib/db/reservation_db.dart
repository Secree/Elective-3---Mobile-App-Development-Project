import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String? id;
  final String from;
  final String to;
  final DateTime createdAt;

  Reservation({
    this.id,
    required this.from,
    required this.to,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'origin': from,
        'destination': to,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'Reservation{id: $id, from: $from, to: $to, at: $createdAt}';

  static Reservation fromMap(Map<String, dynamic> m, String documentId) =>
      Reservation(
        id: documentId,
        from: m['origin'] as String,
        to: m['destination'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  Reservation copyWith({
    String? id,
    String? from,
    String? to,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      createdAt: createdAt ?? this.createdAt,
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
