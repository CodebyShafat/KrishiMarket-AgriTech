import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bulk_offer_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/entities/bulk_offer_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';

class BuyerOffersListScreen extends StatefulWidget {
  final BulkRequirementEntity requirement;

  const BuyerOffersListScreen({super.key, required this.requirement});

  @override
  State<BuyerOffersListScreen> createState() => _BuyerOffersListScreenState();
}

class _BuyerOffersListScreenState extends State<BuyerOffersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BulkOfferProvider>().loadOffersForRequirement(
        widget.requirement.requirementId,
      );
    });
  }

  void _acceptOffer(
    BulkOfferEntity offer,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final remainingReq =
        widget.requirement.requiredQuantity -
        widget.requirement.fulfilledQuantity;
    double acceptedQty = offer.availableQuantity > remainingReq
        ? remainingReq
        : offer.availableQuantity;

    final qtyController = TextEditingController(text: acceptedQty.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.acceptOffer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Max available: ${offer.availableQuantity}'),
            Text('Remaining requirement: $remainingReq'),
            const SizedBox(height: 16),
            TextFormField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Accepted Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.parse(qtyController.text);
              context.read<BulkOfferProvider>().acceptOffer(offer.offerId, qty);
              Navigator.pop(ctx);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<BulkOfferProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offers),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'low') provider.sortOffersByPrice(true);
              if (value == 'high') provider.sortOffersByPrice(false);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'low', child: Text(l10n.priceLowToHigh)),
              PopupMenuItem(value: 'high', child: Text(l10n.priceHighToLow)),
            ],
          ),
        ],
      ),
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
                              offer.farmerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              offer.status.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${offer.availableQuantity} ${offer.unit} @ ₹${offer.offeredPrice}/${offer.unit}',
                        ),
                        Text('${l10n.quality}: ${offer.qualityGrade}'),
                        Text(
                          '${l10n.readyDate}: ${offer.estimatedReadyDate.toLocal().toString().split(' ')[0]}',
                        ),
                        const SizedBox(height: 8),
                        Text('${l10n.farmerNote}: ${offer.note}'),
                        if (offer.status == BulkOfferStatus.accepted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Accepted Qty: ${offer.acceptedQuantity}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (offer.status == BulkOfferStatus.submitted ||
                            offer.status == BulkOfferStatus.shortlisted)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  provider.rejectOffer(offer.offerId);
                                },
                                child: Text(
                                  l10n.rejectOffer,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _acceptOffer(offer, context, l10n),
                                child: Text(l10n.acceptOffer),
                              ),
                            ],
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
