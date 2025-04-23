import 'package:cloud_firestore/cloud_firestore.dart';

class SwapHistory {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final String ownerId;
  final String ownerName;
  final String requesterId;
  final String requesterName;
  final DateTime swapDate;
  final String status; // 'completed', 'cancelled'
  final String location;

  SwapHistory({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.requesterId,
    required this.requesterName,
    required this.swapDate,
    required this.status,
    required this.location,
  });

  factory SwapHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapHistory(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookImageUrl: data['bookImageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      swapDate: (data['swapDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookImageUrl': bookImageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'swapDate': Timestamp.fromDate(swapDate),
      'status': status,
      'location': location,
    };
  }
} 