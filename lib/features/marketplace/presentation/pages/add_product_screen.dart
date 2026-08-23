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
    'Other',
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
    _quantityController = TextEditingController(
      text: p?.availableQuantity.toString() ?? '',
    );
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
      final farmerId = authProvider.currentUser?.id ?? 'test-farmer-id';

      final product = ProductEntity(
        productId:
            widget.productToEdit?.productId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
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
                validator: (val) =>
                    val == null || val.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(labelText: l10n.category),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
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
                        if (val == null || val.isEmpty) {
                          return l10n.validationRequired;
                        }
                        final d = double.tryParse(val);
                        if (d == null || d <= 0) {
                          return l10n.validationNumeric;
                        }
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
                      validator: (val) => val == null || val.isEmpty
                          ? l10n.validationRequired
                          : null,
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
                  if (val == null || val.isEmpty) {
                    return l10n.validationRequired;
                  }
                  final d = double.tryParse(val);
                  if (d == null || d <= 0) {
                    return l10n.validationNumeric;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: l10n.location),
                validator: (val) =>
                    val == null || val.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.harvestDate}: ${_harvestDate.toLocal().toString().split(' ')[0]}',
                    ),
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
