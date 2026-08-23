import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/customer_product_card.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class CustomerMarketplaceScreen extends StatefulWidget {
  const CustomerMarketplaceScreen({super.key});

  @override
  State<CustomerMarketplaceScreen> createState() =>
      _CustomerMarketplaceScreenState();
}

class _CustomerMarketplaceScreenState extends State<CustomerMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<MarketplaceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketplace),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (context.watch<CartProvider>().items.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${context.watch<CartProvider>().items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchSection(context, provider, l10n, user?.location),
          _buildCategoryFilters(context, provider, l10n),
          _buildSortRow(context, provider, l10n),
          const Divider(height: 1),
          Expanded(child: _buildProductList(provider, l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchSection(
    BuildContext context,
    MarketplaceProvider provider,
    AppLocalizations l10n,
    String? location,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                location ?? 'Select Location',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchProducts,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) => provider.setSearchQuery(value.trim()),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    MarketplaceProvider provider,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          final isSelected = cat == provider.selectedCategory;

          // Localization map for categories
          String localizedCat = cat;
          switch (cat) {
            case 'All':
              localizedCat = l10n.all;
              break;
            case 'Wheat':
              localizedCat = l10n.wheat;
              break;
            case 'Rice':
              localizedCat = l10n.rice;
              break;
            case 'Potato':
              localizedCat = l10n.potato;
              break;
            case 'Onion':
              localizedCat = l10n.onion;
              break;
            case 'Tomato':
              localizedCat = l10n.tomato;
              break;
            case 'Vegetables':
              localizedCat = l10n.vegetables;
              break;
            case 'Fruits':
              localizedCat = l10n.fruits;
              break;
            case 'Pulses':
              localizedCat = l10n.pulses;
              break;
            case 'Spices':
              localizedCat = l10n.spices;
              break;
            case 'Other':
              localizedCat = l10n.other;
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(localizedCat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.setCategory(cat);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortRow(
    BuildContext context,
    MarketplaceProvider provider,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.nearbyProducts,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          DropdownButton<SortOption>(
            value: provider.currentSort,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort, size: 20),
            items: [
              DropdownMenuItem(
                value: SortOption.priceLowToHigh,
                child: Text(l10n.priceLowToHigh),
              ),
              DropdownMenuItem(
                value: SortOption.priceHighToLow,
                child: Text(l10n.priceHighToLow),
              ),
              DropdownMenuItem(
                value: SortOption.nearest,
                child: Text(l10n.nearest),
              ),
            ],
            onChanged: (val) {
              if (val != null) provider.setSortOption(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(
    MarketplaceProvider provider,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noProductsFound,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              child: Text(l10n.clear),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return CustomerProductCard(
          product: product,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.productDetails,
              arguments: product,
            );
          },
        );
      },
    );
  }
}
