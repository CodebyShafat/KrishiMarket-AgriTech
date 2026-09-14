import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/utils/category_localizer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddProductScreen extends StatefulWidget {
  final ProductEntity? productToEdit;

  const AddProductScreen({
    super.key,
    this.productToEdit,
  });

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

    _nameController = TextEditingController(
      text: p?.name ?? '',
    );

    _descriptionController = TextEditingController(
      text: p?.description ?? '',
    );

    _qualityController = TextEditingController(
      text: p?.qualityGrade ?? '',
    );

    _priceController = TextEditingController(
      text: p?.price.toString() ?? '',
    );

    _unitController = TextEditingController(
      text: p?.unit ?? 'kg',
    );

    _quantityController = TextEditingController(
      text: p?.availableQuantity.toString() ?? '',
    );

    _locationController = TextEditingController(
      text: p?.location ?? '',
    );

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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final farmerId =
        authProvider.currentUser?.id ?? 'test-farmer-id';

    final product = ProductEntity(
      productId:
      widget.productToEdit?.productId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: farmerId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      qualityGrade: _qualityController.text.trim(),
      price: double.parse(_priceController.text),
      unit: _unitController.text.trim(),
      availableQuantity:
      double.parse(_quantityController.text),
      location: _locationController.text.trim(),
      harvestDate: _harvestDate,
      isAvailable:
      widget.productToEdit?.isAvailable ?? true,
      createdAt:
      widget.productToEdit?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.productToEdit == null) {
        await context
            .read<ProductProvider>()
            .addProduct(product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.productAdded,
              ),
            ),
          );
        }
      } else {
        await context
            .read<ProductProvider>()
            .updateProduct(product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.productUpdated,
              ),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bool isEditing =
        widget.productToEdit != null;

    final bool isLoading =
        context.watch<ProductProvider>().isLoading;

    final String harvestDate =
        _harvestDate
            .toLocal()
            .toString()
            .split(' ')
            .first;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? l10n.editProduct
              : l10n.addProduct,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                // -----------------------------
                // PRODUCT NAME
                // -----------------------------
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.productName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null ||
                        val.trim().isEmpty) {
                      return l10n.validationRequired;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // CATEGORY
                // -----------------------------
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,

                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                  ),

                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,

                      child: Text(
                        CategoryLocalizer
                            .getLocalizedCategory(
                          category,
                          l10n,
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      // IMPORTANT:
                      // Keep English/canonical value
                      // for backend/database.
                      _selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // DESCRIPTION
                // -----------------------------
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // QUALITY
                // -----------------------------
                TextFormField(
                  controller: _qualityController,
                  decoration: InputDecoration(
                    labelText: l10n.quality,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // PRICE + UNIT
                // -----------------------------
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,

                        decoration: InputDecoration(
                          labelText: l10n.price,
                          border:
                          const OutlineInputBorder(),
                        ),

                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        validator: (val) {
                          if (val == null ||
                              val.trim().isEmpty) {
                            return l10n.validationRequired;
                          }

                          final d =
                          double.tryParse(val);

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

                        decoration: InputDecoration(
                          labelText: l10n.unit,
                          border:
                          const OutlineInputBorder(),
                        ),

                        validator: (val) {
                          if (val == null ||
                              val.trim().isEmpty) {
                            return l10n.validationRequired;
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // QUANTITY
                // -----------------------------
                TextFormField(
                  controller: _quantityController,

                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    border: const OutlineInputBorder(),
                  ),

                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (val) {
                    if (val == null ||
                        val.trim().isEmpty) {
                      return l10n.validationRequired;
                    }

                    final d =
                    double.tryParse(val);

                    if (d == null || d <= 0) {
                      return l10n.validationNumeric;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // -----------------------------
                // LOCATION
                // -----------------------------
                TextFormField(
                  controller: _locationController,

                  decoration: InputDecoration(
                    labelText: l10n.location,
                    border: const OutlineInputBorder(),
                  ),

                  validator: (val) {
                    if (val == null ||
                        val.trim().isEmpty) {
                      return l10n.validationRequired;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // -----------------------------
                // HARVEST DATE
                // -----------------------------
                //
                // IMPORTANT:
                // This is deliberately constrained.
                // The previous Row could end up giving
                // the button an infinite width.
                //
                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 4,
                  ),

                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.harvestDate}: $harvestDate',

                          style:
                          const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 110,

                        child: ElevatedButton(
                          onPressed: () =>
                              _selectDate(context),

                          style:
                          ElevatedButton.styleFrom(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical: 12,
                            ),

                            textStyle:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          child: Text(
                            l10n.edit,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // -----------------------------
                // SAVE / UPDATE
                // -----------------------------
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : _saveProduct,

                    style:
                    ElevatedButton.styleFrom(
                      minimumSize:
                      const Size.fromHeight(52),
                    ),

                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      isEditing
                          ? l10n.updateProduct
                          : l10n.saveProduct,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}