import 'package:flutter/foundation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadFarmerProducts(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getFarmerProducts(farmerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductEntity product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createProduct(product);
      _products.add(product);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductEntity product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProduct(product);
      final index = _products.indexWhere(
        (p) => p.productId == product.productId,
      );
      if (index >= 0) {
        _products[index] = product;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(productId);
      _products.removeWhere((p) => p.productId == productId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleAvailability(productId);
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index >= 0) {
        final p = _products[index];
        _products[index] = p.copyWith(isAvailable: !p.isAvailable);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
