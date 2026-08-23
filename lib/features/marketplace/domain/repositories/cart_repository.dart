import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCart(String customerId);
  Future<void> addToCart(String customerId, CartItemEntity item);
  Future<void> updateQuantity(
    String customerId,
    String productId,
    double quantity,
  );
  Future<void> removeFromCart(String customerId, String productId);
  Future<void> clearCart(String customerId);
}
