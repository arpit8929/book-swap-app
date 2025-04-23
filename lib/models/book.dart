import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final String condition;
  final List<String> genres;
  final DateTime dateAdded;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  final String language;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.condition,
    required this.genres,
    required this.dateAdded,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'condition': condition,
      'genres': genres,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
      'language': language,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // Handle genres that might be a map or an array
    List<String> parseGenres(dynamic genres) {
      if (genres == null) return [];
      if (genres is List) {
        return List<String>.from(genres);
      }
      if (genres is Map) {
        return genres.values.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Handle different date formats
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      }
      if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      genres: parseGenres(json['genres']),
      dateAdded: parseDate(json['dateAdded']),
      isAvailable: json['isAvailable'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      language: json['language'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => toJson();
} 