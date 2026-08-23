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
    final isBuyer =
        user?.role == 'Bulk Buyer' && user?.id == requirement.buyerId;
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
                Text(
                  requirement.requirementId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  requirement.status.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.requiredQuantity),
                Text(
                  '${requirement.requiredQuantity} ${requirement.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fulfilled Quantity'),
                Text(
                  '${requirement.fulfilledQuantity} ${requirement.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.targetPrice),
                Text(
                  '₹${requirement.targetPrice}/${requirement.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.deliveryLocation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(requirement.deliveryLocation),
            const SizedBox(height: 16),
            Text(
              l10n.requiredBy,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(requirement.requiredByDate.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 16),
            Text(
              l10n.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(requirement.description),
            const SizedBox(height: 32),

            if (isBuyer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.buyerOffersList,
                      arguments: requirement,
                    );
                  },
                  child: Text('${l10n.viewOffers} (${requirement.offerCount})'),
                ),
              ),

            if (isBuyer &&
                (requirement.status == BulkRequirementStatus.open ||
                    requirement.status ==
                        BulkRequirementStatus.partiallyFulfilled))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    provider.cancelRequirement(requirement.requirementId);
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.cancelOrder,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),

            if (isFarmer &&
                (requirement.status == BulkRequirementStatus.open ||
                    requirement.status ==
                        BulkRequirementStatus.partiallyFulfilled))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.submitBulkOffer,
                      arguments: requirement,
                    );
                  },
                  child: Text(l10n.submitOffer),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
