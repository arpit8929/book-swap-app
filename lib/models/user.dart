import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final List<String> favoriteBooks;
  final List<String> ownedBooks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.favoriteBooks = const [],
    this.ownedBooks = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      favoriteBooks: (map['favoriteBooks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      ownedBooks: (map['ownedBooks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] is Timestamp ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'favoriteBooks': favoriteBooks,
      'ownedBooks': ownedBooks,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? favoriteBooks,
    List<String>? ownedBooks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      ownedBooks: ownedBooks ?? this.ownedBooks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 