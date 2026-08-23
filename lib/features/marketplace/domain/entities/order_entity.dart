enum OrderStatus {
  placed,
  accepted,
  preparing,
  readyForPickup,
  completed,
  cancelled,
}

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
