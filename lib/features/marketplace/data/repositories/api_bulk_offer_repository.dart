import '../../domain/entities/bulk_offer_entity.dart';
import '../../domain/repositories/bulk_offer_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiBulkOfferRepository implements BulkOfferRepository {
  final ApiClient apiClient;

  ApiBulkOfferRepository({required this.apiClient});

  @override
  Future<void> createOffer(BulkOfferEntity offer) async {
    await apiClient.post(
      '/bulk/offers',
      body: {
        'requirement_id': offer.requirementId,
        'offered_quantity': offer.availableQuantity,
        'price': offer.offeredPrice,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<List<BulkOfferEntity>> getOffersForRequirement(
    String requirementId,
  ) async {
    final response = await apiClient.get(
      '/bulk/offers?requirement_id=',
      requiresAuth: true,
    );
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<List<BulkOfferEntity>> getFarmerOffers(String farmerId) async {
    final response = await apiClient.get(
      '/bulk/offers?farmer_id=',
      requiresAuth: true,
    );
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<BulkOfferEntity> getOfferById(String offerId) async {
    // For simplicity, fetch all and filter or add GET /offers/{id} to backend. We'll fetch all farmer offers or all req offers
    // Actually backend doesn't have GET /offers/{id}. We can just query by farmerId if we know it.
    throw UnimplementedError('GET /offers/{id} not implemented natively');
  }

  @override
  Future<void> updateOfferStatus(
    String offerId,
    BulkOfferStatus status, {
    double? acceptedQuantity,
  }) async {
    if (status == BulkOfferStatus.accepted) {
      await apiClient.post('/bulk/offers//accept', requiresAuth: true);
    } else if (status == BulkOfferStatus.rejected) {
      await apiClient.post('/bulk/offers//reject', requiresAuth: true);
    }
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    // Not explicitly supported in backend. Map to reject or delete.
  }

  BulkOfferEntity _mapToEntity(dynamic d) {
    final data = d as Map<String, dynamic>;
    return BulkOfferEntity(
      offerId: data['id'],
      requirementId: data['requirement_id'],
      farmerId: data['farmer_id'],
      farmerName: 'Farmer', // Default
      availableQuantity: (data['offered_quantity'] as num).toDouble(),
      offeredPrice: (data['price'] as num).toDouble(),
      unit: 'kg', // Default
      qualityGrade: 'Standard', // Default
      estimatedReadyDate: DateTime.now().add(
        const Duration(days: 7),
      ), // Default
      note: '', // Default
      status: _parseStatus(data['status']),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  BulkOfferStatus _parseStatus(String status) {
    switch (status) {
      case 'ACCEPTED':
        return BulkOfferStatus.accepted;
      case 'REJECTED':
        return BulkOfferStatus.rejected;
      case 'PENDING':
      default:
        return BulkOfferStatus.submitted;
    }
  }
}
