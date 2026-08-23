import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bulk_requirement_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class CreateBulkRequirementScreen extends StatefulWidget {
  const CreateBulkRequirementScreen({super.key});

  @override
  State<CreateBulkRequirementScreen> createState() =>
      _CreateBulkRequirementScreenState();
}

class _CreateBulkRequirementScreenState
    extends State<CreateBulkRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _requiredByDate;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_requiredByDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }

      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      final req = BulkRequirementEntity(
        requirementId:
            'BR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        buyerId: user.id,
        buyerName: user.fullName ?? 'Unknown',
        productName: _productNameController.text,
        category: _categoryController.text,
        requiredQuantity: double.parse(_quantityController.text),
        unit: 'kg',
        targetPrice: double.parse(_priceController.text),
        deliveryLocation: _locationController.text,
        requiredByDate: _requiredByDate!,
        description: _descriptionController.text,
        status: BulkRequirementStatus.open,
        createdAt: DateTime.now(),
      );

      try {
        await context.read<BulkRequirementProvider>().createRequirement(req);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createRequirement)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: l10n.product,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.requiredQuantity,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.targetPrice,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.deliveryLocation,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _requiredByDate = date);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.requiredBy,
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _requiredByDate == null
                        ? 'Select Date'
                        : _requiredByDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.publish),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
