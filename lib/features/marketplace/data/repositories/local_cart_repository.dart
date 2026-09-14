import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class LocalCartRepository implements CartRepository {
  static const _cartKeyPrefix = 'cart_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<CartItemEntity>> getCart(String customerId) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString('${_cartKeyPrefix}_$customerId');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => CartItemEntity(
        productId: j['productId'],
        farmerId: j['farmerId'],
        productName: j['productName'],
        farmerName: j['farmerName'],
        price: (j['price'] as num).toDouble(),
        unit: j['unit'],
        quantity: (j['quantity'] as num).toDouble(),
        availableQuantity: (j['availableQuantity'] as num).toDouble(),
        quality: j['quality'] ?? '',
      )).toList();
    }
    return [];
  }

  Future<void> _saveCart(String customerId, List<CartItemEntity> cart) async {
    final prefs = await _prefs;
    final jsonList = cart.map((c) => {
      'productId': c.productId,
      'farmerId': c.farmerId,
      'productName': c.productName,
      'farmerName': c.farmerName,
      'price': c.price,
      'unit': c.unit,
      'quantity': c.quantity,
      'availableQuantity': c.availableQuantity,
      'quality': c.quality,
    }).toList();
    await prefs.setString('${_cartKeyPrefix}_$customerId', jsonEncode(jsonList));
  }

  @override
  Future<void> addToCart(String customerId, CartItemEntity item) async {
    final cart = await getCart(customerId);
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
    await _saveCart(customerId, cart);
  }

  @override
  Future<void> updateQuantity(
    String customerId,
    String productId,
    double quantity,
  ) async {
    final cart = await getCart(customerId);
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
    await _saveCart(customerId, cart);
  }

  @override
  Future<void> removeFromCart(String customerId, String productId) async {
    final cart = await getCart(customerId);
    cart.removeWhere((c) => c.productId == productId);
    await _saveCart(customerId, cart);
  }

  @override
  Future<void> clearCart(String customerId) async {
    final prefs = await _prefs;
    await prefs.remove('${_cartKeyPrefix}_$customerId');
  }
}
