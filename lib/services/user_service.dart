import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_swap/models/user.dart';

class UserService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile({String? name, String? email}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // First update Firebase Auth
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      // Update email in Firebase Auth if provided and changed
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      // Create update data map
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (email != null && email.isNotEmpty) {
        updateData['email'] = email;
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Force reload user to get updated data
      await user.reload();
    } catch (e) {
      print('Error updating user profile: $e');
      throw e.toString();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create user document if it doesn't exist
        final userData = {
          'id': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'favoriteBooks': [],
          'ownedBooks': [],
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
        return User(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
      }

      final data = doc.data()!;
      data['id'] = user.uid; // Ensure ID is set
      return User.fromMap(data);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        print('User document does not exist for ID: $userId');
        return 'Unknown User';
      }

      final data = doc.data()!;
      final name = data['name'] as String?;
      
      if (name == null || name.isEmpty) {
        print('Name is null or empty for user ID: $userId');
        return 'Unknown User';
      }

      print('Successfully retrieved user name: $name for ID: $userId');
      return name;
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown User';
    }
  }

  Future<void> addFavoriteBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _firestore.collection('users').doc(user.uid).update({
        'favoriteBooks': FieldValue.arrayUnion([bookId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite book: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _firestore.collection('users').doc(user.uid).update({
        'favoriteBooks': FieldValue.arrayRemove([bookId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing favorite book: $e');
      rethrow;
    }
  }
} 