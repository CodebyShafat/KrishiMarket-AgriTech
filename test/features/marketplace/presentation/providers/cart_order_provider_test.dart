import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_cart_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_order_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/marketplace/domain/entities/cart_item_entity.dart';
import 'package:krishimarket/features/marketplace/domain/entities/order_entity.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/cart_provider.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/order_provider.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;
    late MockCartRepository cartRepo;
    const customerId = 'cust1';

    setUp(() {
      cartRepo = MockCartRepository();
      cartProvider = CartProvider(cartRepo);
    });

    test('Add item to cart', () async {
      final item = CartItemEntity(
        productId: 'p1',
        farmerId: 'f1',
        productName: 'Wheat',
        farmerName: 'Manoj',
        price: 20,
        unit: 'kg',
        quantity: 5,
        quality: 'A',
        availableQuantity: 100,
      );

      await cartProvider.addToCart(customerId, item);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.cartTotal, 100);
    });

    test('Duplicate item increases quantity up to available', () async {
      final item = CartItemEntity(
        productId: 'p1',
        farmerId: 'f1',
        productName: 'Wheat',
        farmerName: 'Manoj',
        price: 20,
        unit: 'kg',
        quantity: 5,
        quality: 'A',
        availableQuantity: 8,
      );

      await cartProvider.addToCart(customerId, item);
      await cartProvider.addToCart(customerId, item);

      expect(cartProvider.items.length, 1);
      // It should cap at 8 because availableQuantity is 8
      expect(cartProvider.items.first.quantity, 8);
    });

    test('Remove item from cart', () async {
      final item = CartItemEntity(
        productId: 'p1',
        farmerId: 'f1',
        productName: 'Wheat',
        farmerName: 'Manoj',
        price: 20,
        unit: 'kg',
        quantity: 5,
        quality: 'A',
        availableQuantity: 10,
      );

      await cartProvider.addToCart(customerId, item);
      await cartProvider.removeFromCart(customerId, 'p1');
      expect(cartProvider.items.isEmpty, true);
    });

    test('Update quantity zero removes item', () async {
      final item = CartItemEntity(
        productId: 'p1',
        farmerId: 'f1',
        productName: 'Wheat',
        farmerName: 'Manoj',
        price: 20,
        unit: 'kg',
        quantity: 5,
        quality: 'A',
        availableQuantity: 10,
      );

      await cartProvider.addToCart(customerId, item);
      await cartProvider.updateQuantity(customerId, 'p1', 0);
      expect(cartProvider.items.isEmpty, true);
    });

    test('Group by farmer', () async {
      final item1 = CartItemEntity(
        productId: 'p1',
        farmerId: 'f1',
        productName: 'W1',
        farmerName: 'F1',
        price: 10,
        unit: 'kg',
        quantity: 1,
        quality: 'A',
        availableQuantity: 10,
      );
      final item2 = CartItemEntity(
        productId: 'p2',
        farmerId: 'f1',
        productName: 'W2',
        farmerName: 'F1',
        price: 10,
        unit: 'kg',
        quantity: 1,
        quality: 'A',
        availableQuantity: 10,
      );
      final item3 = CartItemEntity(
        productId: 'p3',
        farmerId: 'f2',
        productName: 'W3',
        farmerName: 'F2',
        price: 10,
        unit: 'kg',
        quantity: 1,
        quality: 'A',
        availableQuantity: 10,
      );

      await cartProvider.addToCart(customerId, item1);
      await cartProvider.addToCart(customerId, item2);
      await cartProvider.addToCart(customerId, item3);

      final grouped = cartProvider.itemsGroupedByFarmer;
      expect(grouped.keys.length, 2);
      expect(grouped['F1']!.length, 2);
      expect(grouped['F2']!.length, 1);
    });
  });

  group('OrderProvider', () {
    late OrderProvider orderProvider;
    late MockOrderRepository orderRepo;
    late MockProductRepository productRepo;

    setUp(() {
      productRepo = MockProductRepository();
      orderRepo = MockOrderRepository(productRepo);
      orderProvider = OrderProvider(orderRepo);
    });

    test('Load customer orders', () async {
      await orderProvider.loadCustomerOrders('test-customer-id');
      expect(orderProvider.orders.isNotEmpty, true);
    });

    test('Create order reduces inventory', () async {
      // p1 is Premium Wheat with 500 kg available initially
      final order = OrderEntity(
        orderId: 'new-123',
        customerId: 'cust1',
        items: [
          OrderItemEntity(
            productId: 'p1',
            farmerId: 'Manoj',
            productName: 'Premium Wheat',
            farmerName: 'Manoj',
            price: 28,
            unit: 'kg',
            quantity: 50,
            subtotal: 1400,
          ),
        ],
        totalAmount: 1400,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
        deliveryLocation: 'Loc',
      );

      await orderProvider.createOrder(order);
      await orderProvider.loadCustomerOrders('cust1');
      expect(orderProvider.orders.length, 1);

      // Check product repo
      final p1 = await productRepo.getProductById('p1');
      expect(p1.availableQuantity, 450); // 500 - 50
    });

    test('Customer can cancel PLACED order', () async {
      await orderProvider.loadCustomerOrders('test-customer-id');
      final placedOrder = orderProvider.orders.firstWhere(
        (o) => o.status == OrderStatus.placed,
      );

      await orderProvider.cancelOrder(placedOrder.orderId);
      final updated = orderProvider.orders.firstWhere(
        (o) => o.orderId == placedOrder.orderId,
      );
      expect(updated.status, OrderStatus.cancelled);
    });

    test('Customer cannot cancel PREPARING order', () async {
      await orderProvider.loadCustomerOrders('test-customer-id');
      final preparingOrder = orderProvider.orders.firstWhere(
        (o) => o.status == OrderStatus.preparing,
      );

      expect(
        () => orderProvider.cancelOrder(preparingOrder.orderId),
        throwsException,
      );
    });

    test('Farmer order filtering strips other farmers items', () async {
      // First, create a multi-farmer order
      final order = OrderEntity(
        orderId: 'multi-1',
        customerId: 'cust1',
        items: [
          OrderItemEntity(
            productId: 'p1',
            farmerId: 'Manoj',
            productName: 'Wheat',
            farmerName: 'Manoj',
            price: 28,
            unit: 'kg',
            quantity: 10,
            subtotal: 280,
          ),
          OrderItemEntity(
            productId: 'p2',
            farmerId: 'Suresh',
            productName: 'Wheat',
            farmerName: 'Suresh',
            price: 30,
            unit: 'kg',
            quantity: 5,
            subtotal: 150,
          ),
        ],
        totalAmount: 430,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
        deliveryLocation: 'Loc',
      );

      await orderProvider.createOrder(order);

      // Load orders for Manoj
      await orderProvider.loadFarmerOrders('Manoj');
      final manojOrder = orderProvider.orders.firstWhere(
        (o) => o.orderId == 'multi-1',
      );

      // Manoj should only see his 1 item and total 280
      expect(manojOrder.items.length, 1);
      expect(manojOrder.items.first.farmerId, 'Manoj');
      expect(manojOrder.totalAmount, 280);
    });
  });
}
