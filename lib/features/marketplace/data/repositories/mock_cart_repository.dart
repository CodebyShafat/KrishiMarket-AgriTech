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

    final existingIndex = cart.indexWhere(
      (c) => c.productId == item.productId && c.farmerId == item.farmerId,
    );

    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      final newQuantity = existingItem.quantity + item.quantity;
      if (newQuantity <= existingItem.availableQuantity) {
        cart[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        cart[existingIndex] = existingItem.copyWith(
          quantity: existingItem.availableQuantity,
        );
      }
    } else {
      cart.add(item);
    }

    _carts[customerId] = cart;
  }

  @override
  Future<void> updateQuantity(
    String customerId,
    String productId,
    double quantity,
  ) async {
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
          cart[index] = existingItem.copyWith(
            quantity: existingItem.availableQuantity,
          );
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
