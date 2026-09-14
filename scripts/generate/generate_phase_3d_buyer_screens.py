import os

files = {
    r"lib\features\marketplace\presentation\pages\create_bulk_requirement_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_requirement_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreateBulkRequirementScreen extends StatefulWidget {
  const CreateBulkRequirementScreen({super.key});

  @override
  State<CreateBulkRequirementScreen> createState() => _CreateBulkRequirementScreenState();
}

class _CreateBulkRequirementScreenState extends State<CreateBulkRequirementScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }
      
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      
      final req = BulkRequirementEntity(
        requirementId: 'BR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        buyerId: user.id,
        buyerName: user.name,
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
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createRequirement ?? 'Create Requirement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: l10n.product ?? 'Product', border: const OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: l10n.category ?? 'Category', border: const OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.requiredQuantity ?? 'Quantity', border: const OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.targetPrice ?? 'Target Price', border: const OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: l10n.deliveryLocation ?? 'Delivery Location', border: const OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                  decoration: InputDecoration(labelText: l10n.requiredBy ?? 'Required By', border: const OutlineInputBorder()),
                  child: Text(_requiredByDate == null ? 'Select Date' : _requiredByDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.description ?? 'Description', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(l10n.publish ?? 'Publish Requirement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\my_bulk_requirements_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_requirement_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MyBulkRequirementsScreen extends StatefulWidget {
  const MyBulkRequirementsScreen({super.key});

  @override
  State<MyBulkRequirementsScreen> createState() => _MyBulkRequirementsScreenState();
}

class _MyBulkRequirementsScreenState extends State<MyBulkRequirementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<BulkRequirementProvider>().loadBuyerRequirements(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<BulkRequirementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequirements ?? 'My Requirements'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.requirements.isEmpty
              ? Center(child: Text(l10n.noRequirements ?? 'No requirements found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.requirements.length,
                  itemBuilder: (context, index) {
                    final req = provider.requirements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.bulkRequirementDetails, arguments: req);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(req.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  _buildStatusChip(req.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${req.requiredQuantity} ${req.unit} @ ₹${req.targetPrice}/${req.unit}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(req.deliveryLocation, style: const TextStyle(color: Colors.grey)),
                                  Text('By: ${req.requiredByDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${req.offerCount} ${l10n.offers ?? 'Offers'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  Text('${req.fulfilledQuantity} / ${req.requiredQuantity} Fulfilled', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createBulkRequirement);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(BulkRequirementStatus status) {
    Color color;
    switch (status) {
      case BulkRequirementStatus.draft: color = Colors.grey; break;
      case BulkRequirementStatus.open: color = Colors.blue; break;
      case BulkRequirementStatus.partiallyFulfilled: color = Colors.orange; break;
      case BulkRequirementStatus.fulfilled: color = Colors.green; break;
      case BulkRequirementStatus.cancelled: color = Colors.red; break;
      case BulkRequirementStatus.expired: color = Colors.purple; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\bulk_requirement_details_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_requirement_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BulkRequirementDetailsScreen extends StatelessWidget {
  final BulkRequirementEntity requirement;

  const BulkRequirementDetailsScreen({super.key, required this.requirement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final isBuyer = user?.role == 'Bulk Buyer' && user?.id == requirement.buyerId;
    final isFarmer = user?.role == 'Farmer';
    final provider = context.watch<BulkRequirementProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(requirement.productName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(requirement.requirementId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(requirement.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.requiredQuantity ?? 'Required Quantity'),
                Text('${requirement.requiredQuantity} ${requirement.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fulfilled Quantity'),
                Text('${requirement.fulfilledQuantity} ${requirement.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.targetPrice ?? 'Target Price'),
                Text('₹${requirement.targetPrice}/${requirement.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(l10n.deliveryLocation ?? 'Delivery Location', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(requirement.deliveryLocation),
            const SizedBox(height: 16),
            Text(l10n.requiredBy ?? 'Required By', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(requirement.requiredByDate.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 16),
            Text(l10n.description ?? 'Description', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(requirement.description),
            const SizedBox(height: 32),
            
            if (isBuyer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.buyerOffersList, arguments: requirement);
                  },
                  child: Text('${l10n.viewOffers ?? 'View Offers'} (${requirement.offerCount})'),
                ),
              ),

            if (isBuyer && (requirement.status == BulkRequirementStatus.open || requirement.status == BulkRequirementStatus.partiallyFulfilled))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    provider.cancelRequirement(requirement.requirementId);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.cancelOrder ?? 'Cancel Requirement', style: const TextStyle(color: Colors.red)),
                ),
              ),

            if (isFarmer && (requirement.status == BulkRequirementStatus.open || requirement.status == BulkRequirementStatus.partiallyFulfilled))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.submitBulkOffer, arguments: requirement);
                  },
                  child: Text(l10n.submitOffer ?? 'Submit Offer'),
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
