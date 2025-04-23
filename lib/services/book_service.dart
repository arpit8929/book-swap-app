import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_swap/models/book.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all books
  Stream<List<Book>> getBooks() {
    print('BookService: Starting getBooks stream');
    return _firestore
        .collection('books')
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
          print('BookService: Received snapshot with ${snapshot.docs.length} books');
          try {
            final books = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Book.fromJson(data);
            }).toList();
            print('BookService: Successfully parsed ${books.length} books');
            return books;
          } catch (e) {
            print('BookService: Error parsing books: $e');
            rethrow;
          }
        });
  }

  // Get user's books
  Stream<List<Book>> getUserBooks(String userId) {
    print('BookService: Getting books for user: $userId');
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
          print('BookService: Received ${snapshot.docs.length} user books');
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Book.fromJson(data);
          }).toList();
        });
  }

  // Get user's favorite books
  Stream<List<Book>> getFavoriteBooks(String userId) {
    print('Getting favorite books for user: $userId');
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .snapshots()
          .asyncMap((snapshot) async {
        print('Received favorites snapshot with ${snapshot.docs.length} favorites');
        final List<Book> books = [];
        final batch = _firestore.batch();
        final invalidFavorites = <DocumentReference>[];

        for (var doc in snapshot.docs) {
          final bookId = doc.data()['bookId'] as String?;
          if (bookId == null) continue;

          print('Fetching book details for favorite ID: $bookId');
          final bookDoc = await _firestore
              .collection('books')
              .doc(bookId)
              .get();

          if (bookDoc.exists) {
            final data = bookDoc.data()!;
            data['id'] = bookDoc.id;
            books.add(Book.fromJson(data));
            print('Added book to favorites: ${data['title']}');
          } else {
            print('Removing invalid favorite reference: $bookId');
            invalidFavorites.add(doc.reference);
          }
        }

        // Clean up invalid favorites
        if (invalidFavorites.isNotEmpty) {
          invalidFavorites.forEach((ref) => batch.delete(ref));
          await batch.commit();
        }

        return books;
      });
    } catch (e) {
      print('Error in getFavoriteBooks: $e');
      return Stream.value([]);
    }
  }

  // Add a new book
  Future<void> addBook(Book book) async {
    print('BookService: Adding new book: ${book.title}');
    try {
      final docRef = await _firestore.collection('books').add(book.toJson());
      print('BookService: Successfully added book with ID: ${docRef.id}');
    } catch (e) {
      print('BookService: Error adding book: $e');
      rethrow;
    }
  }

  // Update a book
  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    await _firestore.collection('books').doc(bookId).update(data);
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    final batch = _firestore.batch();
    
    // Delete the book document
    final bookRef = _firestore.collection('books').doc(bookId);
    batch.delete(bookRef);
    
    // Get all users who have this book in their favorites
    final usersWithFavorite = await _firestore
        .collectionGroup('favorites')
        .where('bookId', isEqualTo: bookId)
        .get();
    
    // Remove the book from all users' favorites
    for (var doc in usersWithFavorite.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Add book to favorites
  Future<void> addToFavorites(String userId, String bookId) async {
    print('Adding book $bookId to favorites for user $userId');
    try {
      // First verify the book exists
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        throw 'Book does not exist';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(bookId)
          .set({
            'bookId': bookId,
            'addedAt': FieldValue.serverTimestamp()
          });
      print('Successfully added book to favorites');
    } catch (e) {
      print('Error adding to favorites: $e');
      throw e.toString();
    }
  }

  // Remove book from favorites
  Future<void> removeFromFavorites(String userId, String bookId) async {
    print('Removing book $bookId from favorites for user $userId');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(bookId)
          .delete();
      print('Successfully removed book from favorites');
    } catch (e) {
      print('Error removing from favorites: $e');
      throw e.toString();
    }
  }

  // Check if a book is in user's favorites
  Future<bool> isBookFavorited(String userId, String bookId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(bookId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Search books
  Stream<List<Book>> searchBooks(String query) {
    return _firestore
        .collection('books')
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Book.fromJson(data);
      }).toList();
    });
  }

  // Get books by genre
  Stream<List<Book>> getBooksByGenre(String genre) {
    return _firestore
        .collection('books')
        .where('genres', arrayContains: genre)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Book.fromJson(data);
      }).toList();
    });
  }
} 