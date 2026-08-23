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
  State<MyBulkRequirementsScreen> createState() =>
      _MyBulkRequirementsScreenState();
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
      appBar: AppBar(title: Text(l10n.myRequirements)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.requirements.isEmpty
          ? Center(child: Text(l10n.noRequirements))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.requirements.length,
              itemBuilder: (context, index) {
                final req = provider.requirements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.bulkRequirementDetails,
                        arguments: req,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              _buildStatusChip(req.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${req.requiredQuantity} ${req.unit} @ ₹${req.targetPrice}/${req.unit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.deliveryLocation,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'By: ${req.requiredByDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${req.offerCount} ${l10n.offers}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                '${req.fulfilledQuantity} / ${req.requiredQuantity} Fulfilled',
                                style: const TextStyle(fontSize: 12),
                              ),
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
      case BulkRequirementStatus.draft:
        color = Colors.grey;
        break;
      case BulkRequirementStatus.open:
        color = Colors.blue;
        break;
      case BulkRequirementStatus.partiallyFulfilled:
        color = Colors.orange;
        break;
      case BulkRequirementStatus.fulfilled:
        color = Colors.green;
        break;
      case BulkRequirementStatus.cancelled:
        color = Colors.red;
        break;
      case BulkRequirementStatus.expired:
        color = Colors.purple;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
