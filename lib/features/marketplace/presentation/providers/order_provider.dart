import 'package:flutter/foundation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider(this._repository);

  List<OrderEntity> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomerOrders(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.getCustomerOrders(customerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFarmerOrders(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.getFarmerOrders(farmerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(OrderEntity order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createOrder(order);
      // We don't automatically reload here since creation often leads to navigation.
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: status);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    // Only PLACED orders can be cancelled.
    final order = _orders.firstWhere((o) => o.orderId == orderId);
    if (order.status != OrderStatus.placed) {
      throw Exception('Only PLACED orders can be cancelled.');
    }
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }
}
