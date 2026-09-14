import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/profile_screen.dart'; // IMPORT PROFILE
import '../../../settings/presentation/pages/settings_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.farmerHome),
            Text(
              '(${enL10n.farmerHome})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.pushNamed(context, '/language');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              try {
                await context.read<AuthProvider>().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/phoneAuth',
                  (route) => false,
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to logout.')),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(context, l10n, enL10n),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.pushNamed(context, '/aiAssistant'),
        child: const Icon(Icons.auto_awesome),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: '${l10n.home} (${enL10n.home})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: '${l10n.profile} (${enL10n.profile})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: '${l10n.settings} (${l10n.settings})',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, AppLocalizations enL10n) {
    if (_currentIndex == 1) {
      return const ProfileScreen();
    }
    if (_currentIndex == 2) {
      return const SettingsScreen();
    }

    // Home Tab
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(l10n.welcome, l10n.welcome, context),
          const SizedBox(height: 16),
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        l10n.myProducts,
                        l10n.myProducts,
                        Icons.inventory,
                        context,
                        () => Navigator.pushNamed(context, '/myProducts'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        l10n.addProduct,
                        l10n.addProduct,
                        Icons.add_circle,
                        context,
                        () => Navigator.pushNamed(context, '/addProduct'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        l10n.myOrders,
                        l10n.myOrders,
                        Icons.list_alt,
                        context,
                        () => Navigator.pushNamed(context, '/myOrders'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        l10n.sales,
                        l10n.sales,
                        Icons.currency_rupee,
                        context,
                        () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        l10n.bulkRequirements,
                        l10n.bulkRequirements,
                        Icons.business,
                        context,
                        () => Navigator.pushNamed(context, '/farmerBulkRequirements'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        l10n.myOffers,
                        l10n.myOffers,
                        Icons.local_offer,
                        context,
                        () => Navigator.pushNamed(context, '/myBulkOffers'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String primary,
    String secondary,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(primary, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '($secondary)',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String primary,
    String secondary,
    IconData icon,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                primary,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '($secondary)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
