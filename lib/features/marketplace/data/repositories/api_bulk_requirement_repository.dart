import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/repositories/bulk_requirement_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiBulkRequirementRepository implements BulkRequirementRepository {
  final ApiClient apiClient;

  ApiBulkRequirementRepository({required this.apiClient});

  @override
  Future<void> createRequirement(BulkRequirementEntity requirement) async {
    await apiClient.post(
      '/bulk/requirements',
      body: {
        'crop': requirement.category,
        'required_quantity': requirement.requiredQuantity,
        'unit': requirement.unit,
        'target_price': requirement.targetPrice,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<List<BulkRequirementEntity>> getBuyerRequirements(
    String buyerId,
  ) async {
    final response = await apiClient.get(
      '/bulk/requirements?buyer_id=',
      requiresAuth: true,
    );
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<List<BulkRequirementEntity>> getOpenRequirements() async {
    final response = await apiClient.get(
      '/bulk/requirements?status=OPEN',
      requiresAuth: true,
    );
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<BulkRequirementEntity> getRequirementById(String requirementId) async {
    final response = await apiClient.get(
      '/bulk/requirements/',
      requiresAuth: true,
    );
    return _mapToEntity(response);
  }

  @override
  Future<void> updateRequirement(BulkRequirementEntity requirement) async {
    await apiClient.put(
      '/bulk/requirements/',
      body: {
        'crop': requirement.category,
        'required_quantity': requirement.requiredQuantity,
        'unit': requirement.unit,
        'target_price': requirement.targetPrice,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<void> cancelRequirement(String requirementId) async {
    await apiClient.delete('/bulk/requirements/', requiresAuth: true);
  }

  @override
  Future<void> updateRequirementStatus(
    String requirementId,
    BulkRequirementStatus status,
  ) async {
    // Not strictly supported by backend API manually except via accept offer or delete.
  }

  BulkRequirementEntity _mapToEntity(dynamic d) {
    final data = d as Map<String, dynamic>;
    return BulkRequirementEntity(
      requirementId: data['id'],
      buyerId: data['buyer_id'],
      buyerName: 'Buyer', // Default
      productName: data['crop'],
      category: data['crop'],
      requiredQuantity: (data['required_quantity'] as num).toDouble(),
      unit: data['unit'],
      targetPrice: (data['target_price'] as num).toDouble(),
      fulfilledQuantity: (data['fulfilled_quantity'] as num).toDouble(),
      deliveryLocation: 'Standard Location', // Default
      requiredByDate: DateTime.now().add(const Duration(days: 7)), // Default
      description: '', // Default
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      status: _parseStatus(data['status']),
    );
  }

  BulkRequirementStatus _parseStatus(String status) {
    switch (status) {
      case 'PARTIALLY_FULFILLED':
        return BulkRequirementStatus.partiallyFulfilled;
      case 'FULFILLED':
        return BulkRequirementStatus.fulfilled;
      case 'OPEN':
      default:
        return BulkRequirementStatus.open;
    }
  }
}
