import os

files = {
    r"lib\features\marketplace\domain\entities\cart_item_entity.dart": """
class CartItemEntity {
  final String productId;
  final String farmerId;
  final String productName;
  final String farmerName;
  final double price;
  final String unit;
  final double quantity;
  final String quality;
  final double availableQuantity;

  CartItemEntity({
    required this.productId,
    required this.farmerId,
    required this.productName,
    required this.farmerName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.quality,
    required this.availableQuantity,
  });

  double get subtotal => price * quantity;

  CartItemEntity copyWith({
    String? productId,
    String? farmerId,
    String? productName,
    String? farmerName,
    double? price,
    String? unit,
    double? quantity,
    String? quality,
    double? availableQuantity,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      productName: productName ?? this.productName,
      farmerName: farmerName ?? this.farmerName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      quality: quality ?? this.quality,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}
""",
    r"lib\features\marketplace\domain\entities\order_entity.dart": """
enum OrderStatus { placed, accepted, preparing, readyForPickup, completed, cancelled }

class OrderItemEntity {
  final String productId;
  final String farmerId;
  final String productName;
  final String farmerName;
  final double price;
  final String unit;
  final double quantity;
  final double subtotal;

  OrderItemEntity({
    required this.productId,
    required this.farmerId,
    required this.productName,
    required this.farmerName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.subtotal,
  });
}

class OrderEntity {
  final String orderId;
  final String customerId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String deliveryLocation;

  OrderEntity({
    required this.orderId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.deliveryLocation,
  });

  OrderEntity copyWith({
    String? orderId,
    String? customerId,
    List<OrderItemEntity>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    String? deliveryLocation,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
    );
  }
}
""",
    r"lib\features\marketplace\domain\repositories\cart_repository.dart": """
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCart(String customerId);
  Future<void> addToCart(String customerId, CartItemEntity item);
  Future<void> updateQuantity(String customerId, String productId, double quantity);
  Future<void> removeFromCart(String customerId, String productId);
  Future<void> clearCart(String customerId);
}
""",
    r"lib\features\marketplace\domain\repositories\order_repository.dart": """
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getCustomerOrders(String customerId);
  Future<List<OrderEntity>> getFarmerOrders(String farmerId);
  Future<OrderEntity> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
""",
    r"lib\features\marketplace\data\repositories\mock_cart_repository.dart": """
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class MockCartRepository implements CartRepository {
  final Map<String, List<CartItemEntity>> _carts = {};

  @override
  Future<List<CartItemEntity>> getCart(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _carts[customerId] ?? [];
  }

  @override
  Future<void> addToCart(String customerId, CartItemEntity item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final cart = _carts[customerId] ?? [];
    
    final existingIndex = cart.indexWhere((c) => c.productId == item.productId && c.farmerId == item.farmerId);
    
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      final newQuantity = existingItem.quantity + item.quantity;
      if (newQuantity <= existingItem.availableQuantity) {
        cart[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        cart[existingIndex] = existingItem.copyWith(quantity: existingItem.availableQuantity);
      }
    } else {
      cart.add(item);
    }
    
    _carts[customerId] = cart;
  }

  @override
  Future<void> updateQuantity(String customerId, String productId, double quantity) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final cart = _carts[customerId] ?? [];
    final index = cart.indexWhere((c) => c.productId == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        final existingItem = cart[index];
        if (quantity <= existingItem.availableQuantity) {
          cart[index] = existingItem.copyWith(quantity: quantity);
        } else {
           cart[index] = existingItem.copyWith(quantity: existingItem.availableQuantity);
        }
      }
    }
    _carts[customerId] = cart;
  }

  @override
  Future<void> removeFromCart(String customerId, String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final cart = _carts[customerId] ?? [];
    cart.removeWhere((c) => c.productId == productId);
    _carts[customerId] = cart;
  }

  @override
  Future<void> clearCart(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _carts.remove(customerId);
  }
}
""",
    r"lib\features\marketplace\presentation\providers\cart_provider.dart": """
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
  
  double get cartTotal => _items.fold(0, (total, item) => total + item.subtotal);

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

  Future<void> updateQuantity(String customerId, String productId, double quantity) async {
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
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
