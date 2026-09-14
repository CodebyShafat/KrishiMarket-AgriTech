import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/profile_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';

class BulkBuyerHomeScreen extends StatefulWidget {
  const BulkBuyerHomeScreen({super.key});

  @override
  State<BulkBuyerHomeScreen> createState() => _BulkBuyerHomeScreenState();
}

class _BulkBuyerHomeScreenState extends State<BulkBuyerHomeScreen> {
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
            Text(l10n.bulkBuyerHome),
            Text(
              '(${enL10n.bulkBuyerHome})',
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
            label: '${l10n.settings} (${enL10n.settings})',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(l10n.welcome, enL10n.welcome, context),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '${l10n.bulkSearch} (${enL10n.bulkSearch})',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                l10n.myRequirements,
                'My Requirements',
                Icons.list_alt,
                context,
                () => Navigator.pushNamed(context, '/myBulkRequirements'),
              ),
              _buildActionCard(
                l10n.createRequirement,
                'Create Requirement',
                Icons.add_box,
                context,
                () => Navigator.pushNamed(context, '/createBulkRequirement'),
              ),
              _buildActionCard(
                l10n.orders,
                enL10n.orders,
                Icons.local_shipping,
                context,
                () {},
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
