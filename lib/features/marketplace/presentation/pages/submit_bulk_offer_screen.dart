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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }

      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      final offer = BulkOfferEntity(
        offerId:
            'O-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        requirementId: widget.requirement.requirementId,
        farmerId: user.id,
        farmerName: user.fullName ?? 'Unknown',
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
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Offer Submitted')));
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
      appBar: AppBar(title: Text(l10n.submitOffer)),
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
              Text(
                'Target Price: ₹${widget.requirement.targetPrice}/${widget.requirement.unit}',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.availableQuantity,
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
                        labelText: l10n.offeredPrice,
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
                controller: _qualityController,
                decoration: InputDecoration(
                  labelText: l10n.quality,
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
                  if (date != null) setState(() => _readyDate = date);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.readyDate,
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _readyDate == null
                        ? 'Select Date'
                        : _readyDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.farmerNote,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.submitOffer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
