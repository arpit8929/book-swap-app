import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap/models/book.dart';
import 'package:book_swap/providers/app_provider.dart';
import 'package:book_swap/constants/theme.dart';
import 'package:book_swap/services/chat_service.dart';
import 'package:book_swap/screens/chat_screen.dart';
import 'package:book_swap/screens/edit_book_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ChatService _chatService = ChatService();
  bool _isLoading = false;

  Future<void> _startChat(BuildContext context, AppProvider appProvider) async {
    if (appProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to start a chat')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final chatId = await _chatService.createOrGetChat(
        currentUserId: appProvider.currentUser!.uid,
        otherUserId: widget.book.ownerId,
        bookTitle: widget.book.title,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              otherUserId: widget.book.ownerId,
              otherUserName: widget.book.ownerName,
              bookTitle: widget.book.title,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBook(BuildContext context, AppProvider appProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await appProvider.deleteBook(widget.book.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting book: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final isOwner = appProvider.currentUser?.uid == widget.book.ownerId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Book Details'),
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookScreen(book: widget.book),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteBook(context, appProvider),
                ),
              ],
              IconButton(
                icon: Icon(
                  appProvider.favoriteBooks.any((b) => b.id == widget.book.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: appProvider.favoriteBooks.any((b) => b.id == widget.book.id)
                      ? Colors.red
                      : null,
                ),
                onPressed: () => appProvider.toggleFavorite(widget.book.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.book.imageUrl != null)
                  Image.network(
                    widget.book.imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.book, size: 100),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book, size: 100),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${widget.book.author}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.book.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Owner', widget.book.ownerName),
                      _buildDetailRow('Condition', widget.book.condition),
                      if (widget.book.language != null)
                        _buildDetailRow('Language', widget.book.language!),
                      const SizedBox(height: 16),
                      const Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.book.genres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: !isOwner && appProvider.currentUser != null
              ? BottomAppBar(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _startChat(context, appProvider),
                      icon: const Icon(Icons.chat),
                      label: const Text('Contact Owner'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 