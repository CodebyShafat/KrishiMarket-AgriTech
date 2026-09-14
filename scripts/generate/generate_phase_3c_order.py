import os

files = {
    r"lib\features\marketplace\data\repositories\mock_order_repository.dart": """
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';

class MockOrderRepository implements OrderRepository {
  final ProductRepository productRepository;
  
  MockOrderRepository(this.productRepository);
  
  final List<OrderEntity> _orders = [
    OrderEntity(
      orderId: 'KM-102381',
      customerId: 'test-customer-id',
      items: [
        OrderItemEntity(
          productId: 'p1',
          farmerId: 'Manoj',
          productName: 'Premium Wheat',
          farmerName: 'Manoj',
          price: 28.0,
          unit: 'kg',
          quantity: 10,
          subtotal: 280.0,
        )
      ],
      totalAmount: 280.0,
      status: OrderStatus.placed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      deliveryLocation: 'Lucknow',
    ),
    OrderEntity(
      orderId: 'KM-102382',
      customerId: 'test-customer-id',
      items: [
        OrderItemEntity(
          productId: 'p2',
          farmerId: 'Suresh',
          productName: 'Grade A Wheat',
          farmerName: 'Suresh',
          price: 30.0,
          unit: 'kg',
          quantity: 5,
          subtotal: 150.0,
        )
      ],
      totalAmount: 150.0,
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      deliveryLocation: 'Lucknow',
    ),
  ];

  @override
  Future<void> createOrder(OrderEntity order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _orders.insert(0, order);
    
    // Reduce inventory using the product repository abstraction
    for (var item in order.items) {
       try {
         final product = await productRepository.getProductById(item.productId);
         final updatedProduct = product.copyWith(
           availableQuantity: product.availableQuantity - item.quantity
         );
         await productRepository.updateProduct(updatedProduct);
       } catch (_) {
         // Ignore for mock if product not found
       }
    }
  }

  @override
  Future<List<OrderEntity>> getCustomerOrders(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  @override
  Future<List<OrderEntity>> getFarmerOrders(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final farmerOrders = <OrderEntity>[];
    
    for (var order in _orders) {
      final farmerItems = order.items.where((i) => i.farmerId == farmerId).toList();
      if (farmerItems.isNotEmpty) {
        // Strip out other farmers' items so the farmer only sees their own
        final farmerTotal = farmerItems.fold<double>(0, (sum, item) => sum + item.subtotal);
        farmerOrders.add(order.copyWith(
          items: farmerItems,
          totalAmount: farmerTotal,
        ));
      }
    }
    return farmerOrders;
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders.firstWhere((o) => o.orderId == orderId, 
      orElse: () => throw Exception('Order not found'));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
    } else {
      throw Exception('Order not found');
    }
  }
}
""",
    r"lib\features\marketplace\presentation\providers\order_provider.dart": """
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
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
