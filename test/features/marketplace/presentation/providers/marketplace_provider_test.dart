import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/marketplace_provider.dart';

void main() {
  late MarketplaceProvider provider;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    provider = MarketplaceProvider(repository);
  });

  group('MarketplaceProvider', () {
    test('initial state', () {
      expect(provider.isLoading, false);
      expect(provider.filteredProducts.isEmpty, true);
    });

    test('loads realistic mock data with multiple farmers for Wheat', () async {
      await provider.loadProducts();
      expect(provider.filteredProducts.length, greaterThan(10));

      provider.setSearchQuery('Wheat');
      final wheatProducts = provider.filteredProducts;
      expect(wheatProducts.length, greaterThanOrEqualTo(3));

      final farmerIds = wheatProducts.map((p) => p.farmerId).toSet();
      expect(farmerIds.length, greaterThanOrEqualTo(3)); // Manoj, Suresh, Vimal
    });

    test('search is case-insensitive', () async {
      await provider.loadProducts();

      provider.setSearchQuery('wheat');
      final lower = provider.filteredProducts;

      provider.setSearchQuery('WHEAT');
      final upper = provider.filteredProducts;

      expect(lower.length, upper.length);
      expect(lower.first.productId, upper.first.productId);
    });

    test('category filtering works', () async {
      await provider.loadProducts();

      provider.setCategory('Rice');
      final riceProducts = provider.filteredProducts;

      expect(riceProducts.every((p) => p.category == 'Rice'), true);
      expect(riceProducts.length, greaterThan(0));
    });

    test('search + category filtering combined', () async {
      await provider.loadProducts();

      provider.setCategory('Wheat');
      provider.setSearchQuery('Grade A');

      final results = provider.filteredProducts;
      expect(results.length, 1);
      expect(results.first.farmerId, 'Suresh'); // Suresh has Grade A Wheat
    });

    test('sorting by price Low to High', () async {
      await provider.loadProducts();
      provider.setCategory('Wheat');
      provider.setSortOption(SortOption.priceLowToHigh);

      final results = provider.filteredProducts;
      expect(results[0].price, 27.0); // Vimal
      expect(results[1].price, 28.0); // Manoj
      expect(results[2].price, 30.0); // Suresh
    });

    test('sorting by price High to Low', () async {
      await provider.loadProducts();
      provider.setCategory('Wheat');
      provider.setSortOption(SortOption.priceHighToLow);

      final results = provider.filteredProducts;
      expect(results[0].price, 30.0); // Suresh
      expect(results[1].price, 28.0); // Manoj
      expect(results[2].price, 27.0); // Vimal
    });

    test('sorting by quantity', () async {
      await provider.loadProducts();
      provider.setCategory('Wheat');
      provider.setSortOption(SortOption.quantity);

      final results = provider.filteredProducts;
      // Vimal 700, Manoj 500, Suresh 300
      expect(results[0].availableQuantity, 700);
      expect(results[1].availableQuantity, 500);
      expect(results[2].availableQuantity, 300);
    });

    test('empty search results', () async {
      await provider.loadProducts();
      provider.setSearchQuery('NonExistentProduct123');

      expect(provider.filteredProducts.isEmpty, true);
    });

    test('clear filters resets state', () async {
      await provider.loadProducts();
      provider.setCategory('Rice');
      provider.setSearchQuery('Basmati');
      provider.setSortOption(SortOption.priceHighToLow);

      provider.clearFilters();

      expect(provider.selectedCategory, 'All');
      expect(provider.searchQuery, '');
      expect(provider.currentSort, SortOption.priceLowToHigh);
      expect(provider.filteredProducts.length, greaterThan(10));
    });
  });
}
