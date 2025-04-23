import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@bookswap.com',
    );
    
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          // Contact Section
          _buildSection(
            title: 'Contact Us',
            icon: Icons.contact_support,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Support'),
                subtitle: const Text('support@bookswap.com'),
                onTap: _launchEmail,
              ),
            ],
          ),

          // FAQs Section
          _buildSection(
            title: 'Frequently Asked Questions',
            icon: Icons.question_answer,
            children: [
              _buildExpandableFaq(
                'How do I add a book?',
                'To add a book:\n'
                '1. Go to "My Books" in your profile\n'
                '2. Tap the + button\n'
                '3. Fill in the book details\n'
                '4. Upload a photo (optional)\n'
                '5. Tap "Save"',
              ),
              _buildExpandableFaq(
                'How do book swaps work?',
                'Book swaps are simple:\n'
                '1. Find a book you want\n'
                '2. Start a chat with the owner\n'
                '3. Agree on swap terms\n'
                '4. Meet and exchange books\n'
                '5. Mark the swap as complete',
              ),
              _buildExpandableFaq(
                'How do I mark a book as unavailable?',
                'In "My Books", tap on the book and use the toggle switch to mark it as unavailable. This helps other users know which books are currently not available for swapping.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpandableFaq(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
} 