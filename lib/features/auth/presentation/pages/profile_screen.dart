import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      final newName = _nameController.text.trim();
      try {
        await context.read<AuthProvider>().completeProfile(fullName: newName);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>();
    final user = authState.currentUser;

    if (user == null) {
      return const Center(child: Text("No user profile found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: user.phone,
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.badge,
                    label: 'Role',
                    value: user.role?.toUpperCase() ?? 'UNKNOWN',
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Full Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: _isEditing
                        ? TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          )
                        : Text(user.fullName ?? 'Not Set', style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: authState.state == AuthState.authenticating ? null : _toggleEdit,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
