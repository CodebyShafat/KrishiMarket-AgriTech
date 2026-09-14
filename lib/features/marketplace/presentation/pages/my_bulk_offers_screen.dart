import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bulk_offer_provider.dart';
import '../../domain/entities/bulk_offer_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/utils/status_localizer.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class MyBulkOffersScreen extends StatefulWidget {
  const MyBulkOffersScreen({super.key});

  @override
  State<MyBulkOffersScreen> createState() => _MyBulkOffersScreenState();
}

class _MyBulkOffersScreenState extends State<MyBulkOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<BulkOfferProvider>().loadFarmerOffers(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<BulkOfferProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOffers)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.offers.isEmpty
          ? Center(child: Text(l10n.noOffers))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.offers.length,
              itemBuilder: (context, index) {
                final offer = provider.offers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID: ${offer.requirementId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              StatusLocalizer.getLocalizedOfferStatus(offer.status, l10n).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${offer.availableQuantity} ${offer.unit} @ ₹${offer.offeredPrice}/${offer.unit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (offer.status == BulkOfferStatus.accepted)
                          Text(
                            '${l10n.acceptedQuantity}: ${offer.acceptedQuantity}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (offer.status == BulkOfferStatus.submitted)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                provider.withdrawOffer(offer.offerId);
                              },
                              child: Text(
                                l10n.withdrawOffer,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
