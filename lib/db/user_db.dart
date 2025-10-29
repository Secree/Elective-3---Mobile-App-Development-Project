import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String? middleInitial;
  final String address;
  final int age;
  final String email;
  final String password;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    this.middleInitial,
    required this.address,
    required this.age,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (middleInitial != null && middleInitial!.isNotEmpty) 'middleInitial': middleInitial,
      'address': address,
      'age': age,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      middleInitial: map['middleInitial'] as String?,
      address: map['address'] as String,
      age: map['age'] as int,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? middleInitial,
    String? address,
    int? age,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleInitial: middleInitial ?? this.middleInitial,
      address: address ?? this.address,
      age: age ?? this.age,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'User{id: $id, email: $email, name: $firstName $lastName}';
}

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  UserDatabase._init();

  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  Future<User> createUser(User user) async {
    try {
      final docRef = await _usersCollection.add(user.toMap());
      return user.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  Future<bool> validateUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return false;
      return user.password == password;
    } catch (e) {
      throw Exception('Error validating user: $e');
    }
  }

  Future<void> close() async {
    // Firestore doesn't require explicit closing
  }
}
