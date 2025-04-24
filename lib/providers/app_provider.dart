import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_swap/services/auth_service.dart';
import 'package:book_swap/services/book_service.dart';
import 'package:book_swap/models/book.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BookService _bookService = BookService();

  User? _currentUser;
  List<Book> _books = [];
  List<Book> _favoriteBooks = [];
  bool _isLoading = false;
  String _error = '';
  ThemeMode _themeMode = ThemeMode.light;  // Default to light theme
  
  // Stream subscriptions
  StreamSubscription<List<Book>>? _booksSubscription;
  StreamSubscription<List<Book>>? _favoriteBooksSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Getters
  User? get currentUser => _currentUser;
  List<Book> get books => _books;
  List<Book> get favoriteBooks => _favoriteBooks;
  bool get isLoading => _isLoading;
  String get error => _error;
  ThemeMode get themeMode => _themeMode;

  AppProvider() {
    print('Initializing AppProvider');
    _init();
  }

  @override
  void dispose() {
    print('Disposing AppProvider');
    _cleanupSubscriptions();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _cleanupSubscriptions() {
    print('Cleaning up subscriptions in AppProvider');
    _booksSubscription?.cancel();
    _favoriteBooksSubscription?.cancel();
    _booksSubscription = null;
    _favoriteBooksSubscription = null;
  }

  void _init() {
    try {
      print('Setting up auth state listener in AppProvider');
      _authSubscription = _authService.authStateChanges.listen((User? user) {
        print('Auth state changed in AppProvider: ${user?.email ?? 'null'}');
        
        // Clean up existing state
        _cleanupSubscriptions();
        _books = [];
        _favoriteBooks = [];
        _error = '';
        _isLoading = false;
        
        // Update current user
        _currentUser = user;
        
        // Load user data if signed in
        if (user != null) {
          print('User is signed in, loading data...');
          _loadUserData();
        } else {
          print('No user signed in');
        }
        
        notifyListeners();
      }, onError: (error) {
        print('Error in auth state listener: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error in _init: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      print('No current user, skipping data load');
      _isLoading = false;
      notifyListeners();
      return;
    }

    print('Starting to load user data for ${_currentUser!.email}');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Cancel existing subscriptions before creating new ones
      _cleanupSubscriptions();

      // Create a completer to track when initial data is loaded
      final dataLoaded = Completer<void>();
      var booksLoaded = false;
      var favoritesLoaded = false;

      // Function to check if all data is loaded
      void checkDataLoaded() {
        if (booksLoaded && favoritesLoaded && !dataLoaded.isCompleted) {
          print('All data loaded successfully');
          dataLoaded.complete();
        }
      }

      // Load books
      print('Setting up books subscription');
      _booksSubscription = _bookService.getBooks().listen(
        (books) {
          print('Received ${books.length} books from Firestore');
          _books = books;
          booksLoaded = true;
          checkDataLoaded();
          notifyListeners();
        },
        onError: (error) {
          print('Error loading books: $error');
          _error = error.toString();
          if (!dataLoaded.isCompleted) {
            dataLoaded.completeError(error);
          }
          notifyListeners();
        },
      );

      // Load favorite books
      print('Setting up favorites subscription');
      _favoriteBooksSubscription = _bookService.getFavoriteBooks(_currentUser!.uid).listen(
        (books) {
          print('Received ${books.length} favorite books');
          _favoriteBooks = books;
          favoritesLoaded = true;
          checkDataLoaded();
          notifyListeners();
        },
        onError: (error) {
          print('Error loading favorite books: $error');
          _error = error.toString();
          if (!dataLoaded.isCompleted) {
            dataLoaded.completeError(error);
          }
          notifyListeners();
        },
      );

      // Wait for initial data load
      await dataLoaded.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Data load timed out');
          throw 'Timeout while loading user data';
        },
      );

    } catch (e) {
      print('Error in _loadUserData: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auth methods
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Attempting to sign in');
      await _authService.signInWithEmailAndPassword(email, password);
      // Auth state listener will handle the rest
    } catch (e) {
      print('Sign in error: $e');
      _error = e.toString().contains('firebase_auth')
          ? 'Invalid email or password'
          : e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    print('AppProvider.register called with email: $email, name: $name');
    
    // Clean up any existing state
    _cleanupSubscriptions();
    _books = [];
    _favoriteBooks = [];
    _error = '';
    _isLoading = true;
    notifyListeners();

    try {
      print('Starting registration process in AppProvider');
      // Sign out any existing user first
      if (_currentUser != null) {
        print('Signing out existing user: ${_currentUser!.email}');
        await _authService.signOut();
        _currentUser = null;
        notifyListeners();
        
        print('Waiting for auth state to clear completely');
        // Increase delay to ensure Firebase auth state is fully cleared
        await Future.delayed(const Duration(seconds: 2));
      }

      // Verify no user is signed in
      final currentAuth = _authService.currentUser;
      if (currentAuth != null) {
        throw 'Previous user session still active. Please try again.';
      }

      print('Creating new user account with Firebase');
      // Create the new user account
      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );
      
      if (userCredential.user == null) {
        throw 'Failed to create user account';
      }
      
      print('Firebase user created: ${userCredential.user?.uid}');
      // Update current user
      _currentUser = userCredential.user;
      notifyListeners();
      
      // Ensure the display name is set
      if (_currentUser?.displayName == null) {
        print('Setting display name for user');
        await _currentUser?.updateDisplayName(name);
        // Force a reload of the user to get updated display name
        print('Reloading user to get updated profile');
        await _currentUser?.reload();
        _currentUser = _authService.currentUser;
        print('Updated user display name: ${_currentUser?.displayName}');
        notifyListeners();
      }
      
      print('Loading initial user data');
      // Load initial user data with retry
      int retryCount = 0;
      while (retryCount < 3) {
        try {
          await _loadUserData();
          break;
        } catch (loadError) {
          print('Error loading user data (attempt ${retryCount + 1}): $loadError');
          retryCount++;
          if (retryCount < 3) {
            await Future.delayed(const Duration(seconds: 1));
          } else {
            throw 'Failed to load user data after 3 attempts';
          }
        }
      }
      
      print('Registration process complete. Current user: ${_currentUser?.email}');
      _isLoading = false;
      notifyListeners();
      
    } catch (e, stackTrace) {
      print('Registration error in AppProvider:');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      
      // Clean up state on error
      _cleanupSubscriptions();
      _books = [];
      _favoriteBooks = [];
      _currentUser = null;
      _error = e.toString().contains('firebase_auth')
          ? 'Registration failed. Email may already be in use.'
          : e.toString();
      _isLoading = false;
      notifyListeners();
      throw _error;
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;  // Prevent multiple sign-out attempts
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Signing out');
      // Clean up subscriptions and state before signing out
      _cleanupSubscriptions();
      _books = [];
      _favoriteBooks = [];
      _currentUser = null;
      await _authService.signOut();
      // Auth state listener will handle the rest
    } catch (e) {
      print('Sign out error: $e');
      _error = e.toString();
    }
    
    // Ensure loading is false even if auth state listener is delayed
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error state
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Book methods
  Future<void> addBook(Book book) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Adding book: ${book.title}');
      await _bookService.addBook(book);
      print('Book added successfully');
    } catch (e) {
      print('Error adding book: $e');
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    if (_currentUser == null) {
      _error = 'Must be logged in to update a book';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Find the existing book
      final existingBook = _books.firstWhere((book) => book.id == bookId);
      
      // Create a new Book object with updated data
      final updatedBook = Book(
        id: existingBook.id,
        title: data['title'] ?? existingBook.title,
        author: data['author'] ?? existingBook.author,
        description: data['description'] ?? existingBook.description,
        imageUrl: data['imageUrl'] ?? existingBook.imageUrl,
        ownerId: existingBook.ownerId,
        ownerName: existingBook.ownerName,
        condition: data['condition'] ?? existingBook.condition,
        genres: List<String>.from(data['genres'] ?? existingBook.genres),
        dateAdded: existingBook.dateAdded,
        isAvailable: data['isAvailable'] ?? existingBook.isAvailable,
        latitude: data['latitude'] ?? existingBook.latitude,
        longitude: data['longitude'] ?? existingBook.longitude,
        language: data['language'] ?? existingBook.language,
      );

      await _bookService.updateBook(updatedBook);
      
      // Update local state
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index != -1) {
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating book: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    if (_currentUser == null) {
      _error = 'Must be logged in to delete a book';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _bookService.deleteBook(bookId);
      // Remove the book from local state
      _books.removeWhere((book) => book.id == bookId);
      // Remove from favorites if it was favorited
      _favoriteBooks.removeWhere((book) => book.id == bookId);
      notifyListeners();
    } catch (e) {
      print('Error deleting book: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String bookId) async {
    if (_currentUser == null) {
      _error = 'Must be logged in to manage favorites';
      notifyListeners();
      return;
    }

    try {
      print('Toggling favorite for book: $bookId');
      final isFavorite = _favoriteBooks.any((book) => book.id == bookId);
      
      if (isFavorite) {
        print('Removing from favorites');
        await _bookService.removeFromFavorites(_currentUser!.uid, bookId);
        _favoriteBooks.removeWhere((book) => book.id == bookId);
      } else {
        print('Adding to favorites');
        await _bookService.addToFavorites(_currentUser!.uid, bookId);
        // Find the book in the books list and add it to favorites
        final book = _books.firstWhere((book) => book.id == bookId);
        _favoriteBooks.add(book);
      }
      
      notifyListeners();
      print('Successfully toggled favorite');
    } catch (e) {
      print('Error toggling favorite: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Theme methods
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Force refresh auth state
  void notifyAuthStateChanged() {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
} 