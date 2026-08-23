import 'package:flutter/foundation.dart';

import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/repositories/bulk_requirement_repository.dart';

class BulkRequirementProvider with ChangeNotifier {
  final BulkRequirementRepository _repository;

  BulkRequirementProvider(this._repository);

  List<BulkRequirementEntity> _requirements = [];
  bool _isLoading = false;
  String? _error;

  List<BulkRequirementEntity> get requirements => _requirements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBuyerRequirements(String buyerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _requirements = await _repository.getBuyerRequirements(buyerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOpenRequirements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _requirements = await _repository.getOpenRequirements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequirement(BulkRequirementEntity requirement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createRequirement(requirement);
      _requirements.insert(0, requirement);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequirement(String requirementId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.cancelRequirement(requirementId);
      final index = _requirements.indexWhere(
        (r) => r.requirementId == requirementId,
      );
      if (index >= 0) {
        _requirements[index] = _requirements[index].copyWith(
          status: BulkRequirementStatus.cancelled,
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
