import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getCustomerOrders(String customerId);
  Future<List<OrderEntity>> getFarmerOrders(String farmerId);
  Future<OrderEntity> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
