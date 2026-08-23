import '../entities/bulk_requirement_entity.dart';

abstract class BulkRequirementRepository {
  Future<void> createRequirement(BulkRequirementEntity requirement);
  Future<List<BulkRequirementEntity>> getBuyerRequirements(String buyerId);
  Future<List<BulkRequirementEntity>> getOpenRequirements();
  Future<BulkRequirementEntity> getRequirementById(String requirementId);
  Future<void> updateRequirement(BulkRequirementEntity requirement);
  Future<void> cancelRequirement(String requirementId);
  Future<void> updateRequirementStatus(
    String requirementId,
    BulkRequirementStatus status,
  );
}
