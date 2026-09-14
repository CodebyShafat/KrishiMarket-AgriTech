import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bulk_requirement_provider.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import 'package:krishimarket/core/utils/status_localizer.dart';

class FarmerBulkRequirementsScreen extends StatefulWidget {
  const FarmerBulkRequirementsScreen({super.key});

  @override
  State<FarmerBulkRequirementsScreen> createState() =>
      _FarmerBulkRequirementsScreenState();
}

class _FarmerBulkRequirementsScreenState
    extends State<FarmerBulkRequirementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BulkRequirementProvider>().loadOpenRequirements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<BulkRequirementProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bulkRequirements)),
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
                              Text(
                                StatusLocalizer.getLocalizedRequirementStatus(req.status, l10n).toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
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
                                '${l10n.requiredBy}: ${req.requiredByDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.grey),
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
    );
  }
}
