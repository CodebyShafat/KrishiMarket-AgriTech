import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiOrderRepository implements OrderRepository {
  final ApiClient apiClient;

  ApiOrderRepository({required this.apiClient});

  @override
  Future<void> createOrder(OrderEntity order) async {
    await apiClient.post(
      '/orders',
      body: {
        'items': order.items
            .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
            .toList(),
      },
      requiresAuth: true,
    );
  }

  @override
  Future<List<OrderEntity>> getCustomerOrders(String customerId) async {
    final response = await apiClient.get('/orders', requiresAuth: true);
    if (response is List) {
      return response
          .map((data) => _mapToEntity(data))
          .where((o) => o.customerId == customerId)
          .toList();
    }
    return [];
  }

  @override
  Future<List<OrderEntity>> getFarmerOrders(String farmerId) async {
    final response = await apiClient.get('/orders', requiresAuth: true);
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    // For simplicity, fetch all and find
    final response = await apiClient.get('/orders', requiresAuth: true);
    if (response is List) {
      final order = response
          .map((data) => _mapToEntity(data))
          .firstWhere((o) => o.orderId == orderId);
      return order;
    }
    throw Exception('Order not found');
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (status == OrderStatus.cancelled) {
      await apiClient.delete('/orders/$orderId', requiresAuth: true);
    }
    // Update order status not fully implemented on backend, except cancel
  }

  OrderEntity _mapToEntity(dynamic d) {
    final data = d as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>? ?? [];
    return OrderEntity(
      orderId: data['id'],
      customerId: data['buyer_id'],
      totalAmount: (data['total_amount'] as num).toDouble(),
      status: _parseStatus(data['status']),
      items: itemsList
          .map(
            (i) => OrderItemEntity(
              productId: i['product_id'],
              quantity: (i['quantity'] as num).toDouble(),
              price: (i['price_at_time'] as num).toDouble(),
              farmerId: i['farmer_id'] ?? '',
              productName: i['product_name'] ?? 'Product',
              farmerName: i['farmer_name'] ?? 'Farmer',
              unit: i['unit'] ?? 'kg',
              subtotal: ((i['price_at_time'] as num) * (i['quantity'] as num))
                  .toDouble(),
            ),
          )
          .toList(),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      deliveryLocation: 'Standard Location', // Default
    );
  }

  OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'PLACED':
      default:
        return OrderStatus.placed;
    }
  }
}
