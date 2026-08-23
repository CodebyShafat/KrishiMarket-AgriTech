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
        ),
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
        ),
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
          availableQuantity: product.availableQuantity - item.quantity,
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
      final farmerItems = order.items
          .where((i) => i.farmerId == farmerId)
          .toList();
      if (farmerItems.isNotEmpty) {
        // Strip out other farmers' items so the farmer only sees their own
        final farmerTotal = farmerItems.fold<double>(
          0,
          (sum, item) => sum + item.subtotal,
        );
        farmerOrders.add(
          order.copyWith(items: farmerItems, totalAmount: farmerTotal),
        );
      }
    }
    return farmerOrders;
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders.firstWhere(
      (o) => o.orderId == orderId,
      orElse: () => throw Exception('Order not found'),
    );
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
