import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
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
            Text(l10n.customerHome),
            Text(
              '(${enL10n.customerHome})',
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
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/phoneAuth',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(l10n.welcome, enL10n.welcome, context),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: '${l10n.searchProducts} (${enL10n.searchProducts})',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.categories, enL10n.categories, context),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryCard(Icons.eco, 'Vegetables', context),
                  _buildCategoryCard(Icons.apple, 'Fruits', context),
                  _buildCategoryCard(Icons.grain, 'Grains', context),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.nearbyFresh, enL10n.nearbyFresh, context),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  l10n.marketplace,
                  'Marketplace',
                  Icons.storefront,
                  context,
                  () => Navigator.pushNamed(context, '/customerMarketplace'),
                ),
                _buildActionCard(
                  l10n.cart,
                  enL10n.cart,
                  Icons.shopping_cart,
                  context,
                  () => Navigator.pushNamed(context, '/cart'),
                ),
                _buildActionCard(
                  l10n.orders,
                  enL10n.orders,
                  Icons.local_shipping,
                  context,
                  () => Navigator.pushNamed(context, '/myOrders'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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

  Widget _buildCategoryCard(IconData icon, String title, BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
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
