import os

files = {
    r"lib\features\marketplace\domain\entities\product_entity.dart": """
class ProductEntity {
  final String productId;
  final String farmerId;
  final String name;
  final String category;
  final String description;
  final String qualityGrade;
  final double price;
  final String unit;
  final double availableQuantity;
  final String location;
  final DateTime harvestDate;
  final bool isAvailable;
  final DateTime createdAt;

  ProductEntity({
    required this.productId,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.description,
    required this.qualityGrade,
    required this.price,
    required this.unit,
    required this.availableQuantity,
    required this.location,
    required this.harvestDate,
    required this.isAvailable,
    required this.createdAt,
  });

  ProductEntity copyWith({
    String? productId,
    String? farmerId,
    String? name,
    String? category,
    String? description,
    String? qualityGrade,
    double? price,
    String? unit,
    double? availableQuantity,
    String? location,
    DateTime? harvestDate,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      location: location ?? this.location,
      harvestDate: harvestDate ?? this.harvestDate,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
""",
    r"lib\features\marketplace\domain\repositories\product_repository.dart": """
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getFarmerProducts(String farmerId);
  Future<ProductEntity> getProductById(String productId);
  Future<void> createProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
  Future<void> toggleAvailability(String productId);
}
""",
    r"lib\features\marketplace\data\models\product_model.dart": """
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.productId,
    required super.farmerId,
    required super.name,
    required super.category,
    required super.description,
    required super.qualityGrade,
    required super.price,
    required super.unit,
    required super.availableQuantity,
    required super.location,
    required super.harvestDate,
    required super.isAvailable,
    required super.createdAt,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      productId: entity.productId,
      farmerId: entity.farmerId,
      name: entity.name,
      category: entity.category,
      description: entity.description,
      qualityGrade: entity.qualityGrade,
      price: entity.price,
      unit: entity.unit,
      availableQuantity: entity.availableQuantity,
      location: entity.location,
      harvestDate: entity.harvestDate,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
    );
  }
}
""",
    r"lib\features\marketplace\data\repositories\mock_product_repository.dart": """
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  final List<ProductEntity> _products = [];

  @override
  Future<List<ProductEntity>> getFarmerProducts(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _products.firstWhere((p) => p.productId == productId, 
      orElse: () => throw Exception('Product not found'));
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(product);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p.productId == product.productId);
    if (index >= 0) {
      _products[index] = product;
    } else {
      throw Exception('Product not found');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.removeWhere((p) => p.productId == productId);
  }

  @override
  Future<void> toggleAvailability(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.productId == productId);
    if (index >= 0) {
      final p = _products[index];
      _products[index] = p.copyWith(isAvailable: !p.isAvailable);
    } else {
      throw Exception('Product not found');
    }
  }
}
""",
    r"lib\features\marketplace\presentation\providers\product_provider.dart": """
import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;
  
  ProductProvider(this._repository);
  
  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  Future<void> loadFarmerProducts(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _products = await _repository.getFarmerProducts(farmerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addProduct(ProductEntity product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _repository.createProduct(product);
      _products.add(product);
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProduct(ProductEntity product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _repository.updateProduct(product);
      final index = _products.indexWhere((p) => p.productId == product.productId);
      if (index >= 0) {
        _products[index] = product;
      }
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _repository.deleteProduct(productId);
      _products.removeWhere((p) => p.productId == productId);
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> toggleAvailability(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _repository.toggleAvailability(productId);
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index >= 0) {
        final p = _products[index];
        _products[index] = p.copyWith(isAvailable: !p.isAvailable);
      }
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
