import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap/providers/app_provider.dart';
import 'package:book_swap/screens/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_swap/constants/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reauthenticateUser(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw 'No user logged in';

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm your new password',
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () {
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoading ? null : () async {
                // Validate inputs
                if (_currentPasswordController.text.isEmpty ||
                    _newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                if (_newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New password must be at least 6 characters')),
                  );
                  return;
                }

                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  // First, reauthenticate the user
                  await _reauthenticateUser(_currentPasswordController.text);
                  
                  // Then update the password
                  await _auth.currentUser?.updatePassword(_newPasswordController.text);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  String message = 'An error occurred';
                  switch (e.code) {
                    case 'wrong-password':
                      message = 'Current password is incorrect';
                      break;
                    case 'requires-recent-login':
                      message = 'Please sign in again before changing your password';
                      break;
                    case 'weak-password':
                      message = 'New password is too weak';
                      break;
                    default:
                      message = e.message ?? 'An error occurred';
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDarkMode = appProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Account',
            [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text('Change Password'),
                onTap: _showChangePasswordDialog,
              ),
            ],
          ),
          _buildSection(
            'Appearance',
            [
              ListTile(
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.primaryColor,
                ),
                title: const Text('Theme'),
                subtitle: Text(isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    appProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? 'Dark theme enabled' : 'Light theme enabled'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: value ? AppTheme.darkSurfaceColor : AppTheme.primaryColor,
                      ),
                    );
                  },
                  activeColor: AppTheme.darkSecondaryColor,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                trailing: const Text('1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
} 