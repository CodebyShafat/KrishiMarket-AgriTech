import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../marketplace/presentation/providers/cart_provider.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: const Text('Logged-in Phone'),
                    subtitle: Text(user?.phone ?? 'Unknown'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Colors.green),
                    title: const Text('Account Role'),
                    subtitle: Text((user?.role ?? 'Unknown').toUpperCase()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shopping_cart_checkout, color: Colors.orange),
                    title: const Text('Clear Local Cart Data'),
                    subtitle: const Text('Remove all items from your cart'),
                    onTap: () async {
                      if (user == null) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        await context.read<CartProvider>().clearCart(user.id);
                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cart data cleared successfully.')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to clear cart data.')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.grey),
                    title: const Text('Delete Account'),
                    subtitle: const Text('Not implemented', style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account deletion is not supported by the backend.')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Clear Local Session (Logout)', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Sign out of your account'),
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.phoneAuth,
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to clear session.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
