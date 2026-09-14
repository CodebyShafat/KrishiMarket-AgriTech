import os

files = {
    r"lib\features\marketplace\presentation\widgets\product_card.dart": """
import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text('${l10n.category}: ${product.category}'),
                    const SizedBox(height: 4),
                    Text('${l10n.price}: ₹${product.price}/${product.unit}'),
                    const SizedBox(height: 4),
                    Text('${l10n.quantity}: ${product.availableQuantity} ${product.unit}'),
                    const SizedBox(height: 4),
                    Text(
                      product.isAvailable ? l10n.available : l10n.unavailable,
                      style: TextStyle(
                        color: product.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                  Switch(
                    value: product.isAvailable,
                    onChanged: (val) => onToggleAvailability(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\my_products_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final farmerId = authProvider.currentUser?.uid ?? 'test-farmer-id';
      context.read<ProductProvider>().loadFarmerProducts(farmerId);
    });
  }

  void _confirmDelete(BuildContext context, String productId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(productId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.productDeleted)),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProducts),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          
          if (provider.products.isEmpty) {
            return Center(child: Text(l10n.noProducts));
          }
          
          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRouter.productDetails, 
                    arguments: product,
                  );
                },
                onEdit: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.addProduct,
                    arguments: product,
                  );
                },
                onDelete: () => _confirmDelete(context, product.productId),
                onToggleAvailability: () {
                  provider.toggleAvailability(product.productId);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addProduct);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\add_product_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddProductScreen extends StatefulWidget {
  final ProductEntity? productToEdit;
  
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _qualityController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;
  
  String _selectedCategory = 'Wheat';
  DateTime _harvestDate = DateTime.now();

  final List<String> _categories = [
    'Wheat',
    'Rice',
    'Potato',
    'Onion',
    'Tomato',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Spices',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _qualityController = TextEditingController(text: p?.qualityGrade ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _unitController = TextEditingController(text: p?.unit ?? 'kg');
    _quantityController = TextEditingController(text: p?.availableQuantity.toString() ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    
    if (p != null) {
      _selectedCategory = p.category;
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
      _harvestDate = p.harvestDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _qualityController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _harvestDate) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final farmerId = authProvider.currentUser?.uid ?? 'test-farmer-id';
      
      final product = ProductEntity(
        productId: widget.productToEdit?.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        farmerId: farmerId,
        name: _nameController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        qualityGrade: _qualityController.text,
        price: double.parse(_priceController.text),
        unit: _unitController.text,
        availableQuantity: double.parse(_quantityController.text),
        location: _locationController.text,
        harvestDate: _harvestDate,
        isAvailable: widget.productToEdit?.isAvailable ?? true,
        createdAt: widget.productToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.productToEdit == null) {
        context.read<ProductProvider>().addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.productAdded)),
        );
      } else {
        context.read<ProductProvider>().updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.productUpdated)),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editProduct : l10n.addProduct),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.productName),
                validator: (val) => val == null || val.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: l10n.category),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    if (val != null) _selectedCategory = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.description),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualityController,
                decoration: InputDecoration(labelText: l10n.quality),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: l10n.price),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return l10n.validationRequired;
                        final d = double.tryParse(val);
                        if (d == null || d <= 0) return l10n.validationNumeric;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(labelText: l10n.unit),
                      validator: (val) => val == null || val.isEmpty ? l10n.validationRequired : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: l10n.quantity),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return l10n.validationRequired;
                  final d = double.tryParse(val);
                  if (d == null || d <= 0) return l10n.validationNumeric;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: l10n.location),
                validator: (val) => val == null || val.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('${l10n.harvestDate}: ${_harvestDate.toLocal().toString().split(' ')[0]}'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(l10n.edit),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(isEditing ? l10n.updateProduct : l10n.saveProduct),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\product_details_screen.dart": """
import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductEntity product;
  
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 64, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.category}: ${product.category}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${l10n.price}: ₹${product.price}/${product.unit}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
                  const SizedBox(height: 8),
                  Text('${l10n.quantity}: ${product.availableQuantity} ${product.unit}', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  Text(l10n.description, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(product.description),
                  const SizedBox(height: 16),
                  Text('${l10n.quality}: ${product.qualityGrade}'),
                  const SizedBox(height: 8),
                  Text('${l10n.location}: ${product.location}'),
                  const SizedBox(height: 8),
                  Text('${l10n.harvestDate}: ${product.harvestDate.toLocal().toString().split(' ')[0]}'),
                  const SizedBox(height: 8),
                  Text(
                    product.isAvailable ? l10n.available : l10n.unavailable,
                    style: TextStyle(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
