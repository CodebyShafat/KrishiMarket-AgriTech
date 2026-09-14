import os

files = {
    r"lib\features\marketplace\presentation\pages\buyer_offers_list_screen.dart": """
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
      context.read<BulkOfferProvider>().loadOffersForRequirement(widget.requirement.requirementId);
    });
  }

  void _acceptOffer(BulkOfferEntity offer, BuildContext context, AppLocalizations l10n) {
    final remainingReq = widget.requirement.requiredQuantity - widget.requirement.fulfilledQuantity;
    double acceptedQty = offer.availableQuantity > remainingReq ? remainingReq : offer.availableQuantity;
    
    final _qtyController = TextEditingController(text: acceptedQty.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.acceptOffer ?? 'Accept Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Max available: ${offer.availableQuantity}'),
            Text('Remaining requirement: $remainingReq'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Accepted Quantity', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel ?? 'Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.parse(_qtyController.text);
              context.read<BulkOfferProvider>().acceptOffer(offer.offerId, qty);
              Navigator.pop(ctx);
            },
            child: Text(l10n.confirm ?? 'Confirm'),
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
        title: Text(l10n.offers ?? 'Offers'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'low') provider.sortOffersByPrice(true);
              if (value == 'high') provider.sortOffersByPrice(false);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'low', child: Text(l10n.priceLowToHigh ?? 'Price: Low to High')),
              PopupMenuItem(value: 'high', child: Text(l10n.priceHighToLow ?? 'Price: High to Low')),
            ],
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.offers.isEmpty
              ? Center(child: Text(l10n.noOffers ?? 'No offers found'))
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
                                Text(offer.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(offer.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${offer.availableQuantity} ${offer.unit} @ ₹${offer.offeredPrice}/${offer.unit}'),
                            Text('${l10n.quality ?? 'Quality'}: ${offer.qualityGrade}'),
                            Text('${l10n.readyDate ?? 'Ready Date'}: ${offer.estimatedReadyDate.toLocal().toString().split(' ')[0]}'),
                            const SizedBox(height: 8),
                            Text('${l10n.farmerNote ?? 'Note'}: ${offer.note}'),
                            if (offer.status == BulkOfferStatus.accepted)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Accepted Qty: ${offer.acceptedQuantity}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            if (offer.status == BulkOfferStatus.submitted || offer.status == BulkOfferStatus.shortlisted)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      provider.rejectOffer(offer.offerId);
                                    },
                                    child: Text(l10n.rejectOffer ?? 'Reject', style: const TextStyle(color: Colors.red)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _acceptOffer(offer, context, l10n),
                                    child: Text(l10n.acceptOffer ?? 'Accept'),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\submit_bulk_offer_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_offer_provider.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/entities/bulk_offer_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SubmitBulkOfferScreen extends StatefulWidget {
  final BulkRequirementEntity requirement;

  const SubmitBulkOfferScreen({super.key, required this.requirement});

  @override
  State<SubmitBulkOfferScreen> createState() => _SubmitBulkOfferScreenState();
}

class _SubmitBulkOfferScreenState extends State<SubmitBulkOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _qualityController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _readyDate;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_readyDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }
      
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      
      final offer = BulkOfferEntity(
        offerId: 'O-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        requirementId: widget.requirement.requirementId,
        farmerId: user.id,
        farmerName: user.name,
        availableQuantity: double.parse(_quantityController.text),
        offeredPrice: double.parse(_priceController.text),
        unit: widget.requirement.unit,
        qualityGrade: _qualityController.text,
        estimatedReadyDate: _readyDate!,
        note: _noteController.text,
        status: BulkOfferStatus.submitted,
        createdAt: DateTime.now(),
      );
      
      try {
        await context.read<BulkOfferProvider>().submitOffer(offer);
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer Submitted')));
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
      appBar: AppBar(title: Text(l10n.submitOffer ?? 'Submit Offer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.requirement.productName} (${widget.requirement.requiredQuantity} ${widget.requirement.unit} required)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Target Price: ₹${widget.requirement.targetPrice}/${widget.requirement.unit}'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.availableQuantity ?? 'Available Quantity', border: const OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.offeredPrice ?? 'Offered Price', border: const OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualityController,
                decoration: InputDecoration(labelText: l10n.quality ?? 'Quality', border: const OutlineInputBorder()),
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
                  if (date != null) setState(() => _readyDate = date);
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.readyDate ?? 'Ready Date', border: const OutlineInputBorder()),
                  child: Text(_readyDate == null ? 'Select Date' : _readyDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.farmerNote ?? 'Farmer Note', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(l10n.submitOffer ?? 'Submit Offer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\farmer_bulk_requirements_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_requirement_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

class FarmerBulkRequirementsScreen extends StatefulWidget {
  const FarmerBulkRequirementsScreen({super.key});

  @override
  State<FarmerBulkRequirementsScreen> createState() => _FarmerBulkRequirementsScreenState();
}

class _FarmerBulkRequirementsScreenState extends State<FarmerBulkRequirementsScreen> {
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
      appBar: AppBar(
        title: Text(l10n.bulkRequirements ?? 'Bulk Requirements'),
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
                                  Text(req.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
""",
    r"lib\features\marketplace\presentation\pages\my_bulk_offers_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bulk_offer_provider.dart';
import '../../domain/entities/bulk_offer_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(l10n.myOffers ?? 'My Offers'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.offers.isEmpty
              ? Center(child: Text(l10n.noOffers ?? 'No offers found'))
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
                                Text('Req: ${offer.requirementId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(offer.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${offer.availableQuantity} ${offer.unit} @ ₹${offer.offeredPrice}/${offer.unit}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                            const SizedBox(height: 8),
                            if (offer.status == BulkOfferStatus.accepted)
                              Text('Accepted Qty: ${offer.acceptedQuantity}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (offer.status == BulkOfferStatus.submitted)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    provider.withdrawOffer(offer.offerId);
                                  },
                                  child: Text(l10n.withdrawOffer ?? 'Withdraw', style: const TextStyle(color: Colors.red)),
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
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
