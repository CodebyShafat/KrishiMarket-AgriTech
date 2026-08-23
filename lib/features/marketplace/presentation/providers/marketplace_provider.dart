import 'package:flutter/foundation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

enum SortOption { priceLowToHigh, priceHighToLow, nearest, quantity }

class MarketplaceProvider with ChangeNotifier {
  final ProductRepository _repository;

  MarketplaceProvider(this._repository);

  List<ProductEntity> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  SortOption _currentSort = SortOption.priceLowToHigh;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  SortOption get currentSort => _currentSort;

  final List<String> categories = [
    'All',
    'Wheat',
    'Rice',
    'Potato',
    'Onion',
    'Tomato',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Spices',
    'Other',
  ];

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _repository.getAllAvailableProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _currentSort = SortOption.priceLowToHigh;
    notifyListeners();
  }

  List<ProductEntity> get filteredProducts {
    var filtered = _allProducts.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.quantity:
        filtered.sort(
          (a, b) => b.availableQuantity.compareTo(a.availableQuantity),
        );
        break;
      case SortOption.nearest:
        // Mock sorting for nearest - just a placeholder, maybe sort by location name alphabetically for now
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
    }

    return filtered;
  }
}
