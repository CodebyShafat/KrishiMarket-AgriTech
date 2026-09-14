import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krishimarket/features/marketplace/data/repositories/local_cart_repository.dart';
import 'package:krishimarket/features/marketplace/domain/entities/cart_item_entity.dart';

void main() {
  test('LocalCartRepository persistence and isolation', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = LocalCartRepository();
    final item1 = CartItemEntity(
      productId: 'p1',
      farmerId: 'f1',
      productName: 'Tomato',
      farmerName: 'Farmer Joe',
      price: 50.0,
      unit: 'kg',
      quantity: 2.0,
      quality: 'A',
      availableQuantity: 10.0,
    );
    
    await repo.addToCart('user_A', item1);
    
    // Reload from new instance
    final repo2 = LocalCartRepository();
    final cartA = await repo2.getCart('user_A');
    
    expect(cartA.length, 1);
    expect(cartA.first.productId, 'p1');
    expect(cartA.first.quality, 'A');
    
    final cartB = await repo2.getCart('user_B');
    expect(cartB.length, 0); // Isolated
  });
}
