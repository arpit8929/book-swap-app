import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get existing chat
  Future<String> createOrGetChat({
    required String currentUserId,
    required String otherUserId,
    String? bookTitle,
  }) async {
    try {
      // Check if chat already exists
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChat.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new chat if none exists
      final chatDoc = await _firestore.collection('chats').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': bookTitle != null ? 'Interested in: $bookTitle' : 'New chat started',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add first message if book title is provided
      if (bookTitle != null) {
        await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .add({
          'senderId': currentUserId,
          'message': 'Hi! I am interested in your book: "$bookTitle".',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return chatDoc.id;
    } catch (e) {
      print('Error creating chat: $e');
      throw e.toString();
    }
  }

  // Get user's chats
  Stream<List<ChatPreview>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatPreview(
          id: doc.id,
          participants: List<String>.from(data['participants']),
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // Get chat messages
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'],
          message: data['message'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isSwapRequest: data['isSwapRequest'] ?? false,
        );
      }).toList();
    });
  }

  // Send message
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String message, {
    bool isSwapRequest = false,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Add message to messages subcollection
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
          
      batch.set(messageRef, {
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isSwapRequest': isSwapRequest,
      });

      // Update chat document with last message
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
      throw e.toString();
    }
  }
}

class ChatPreview {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatPreview({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isSwapRequest;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.isSwapRequest = false,
  });
} 