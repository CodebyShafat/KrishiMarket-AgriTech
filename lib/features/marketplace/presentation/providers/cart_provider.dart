import 'package:flutter/foundation.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _repository;

  CartProvider(this._repository);

  List<CartItemEntity> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemEntity> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get cartTotal =>
      _items.fold(0, (total, item) => total + item.subtotal);

  Map<String, List<CartItemEntity>> get itemsGroupedByFarmer {
    final map = <String, List<CartItemEntity>>{};
    for (var item in _items) {
      if (!map.containsKey(item.farmerName)) {
        map[item.farmerName] = [];
      }
      map[item.farmerName]!.add(item);
    }
    return map;
  }

  Future<void> loadCart(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.getCart(customerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String customerId, CartItemEntity item) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.addToCart(customerId, item);
      _items = await _repository.getCart(customerId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(
    String customerId,
    String productId,
    double quantity,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateQuantity(customerId, productId, quantity);
      _items = await _repository.getCart(customerId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String customerId, String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.removeFromCart(customerId, productId);
      _items = await _repository.getCart(customerId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.clearCart(customerId);
      _items = [];
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
