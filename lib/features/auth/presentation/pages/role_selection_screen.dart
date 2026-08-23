import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../../core/routing/app_router.dart';
import '../widgets/primary_button.dart';
import '../widgets/selection_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.whoAreYou,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '(${enL10n.whoAreYou})',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    SelectionCard(
                      titlePrimary: l10n.farmer,
                      titleSecondary: enL10n.farmer,
                      icon: Icons.agriculture,
                      isSelected: _selectedRole == 'farmer',
                      onTap: () => setState(() => _selectedRole = 'farmer'),
                    ),
                    const SizedBox(height: 16),
                    SelectionCard(
                      titlePrimary: l10n.customer,
                      titleSecondary: enL10n.customer,
                      icon: Icons.shopping_cart,
                      isSelected: _selectedRole == 'customer',
                      onTap: () => setState(() => _selectedRole = 'customer'),
                    ),
                    const SizedBox(height: 16),
                    SelectionCard(
                      titlePrimary: l10n.bulkBuyer,
                      titleSecondary: enL10n.bulkBuyer,
                      icon: Icons.storefront,
                      isSelected: _selectedRole == 'bulk_buyer',
                      onTap: () => setState(() => _selectedRole = 'bulk_buyer'),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                titlePrimary: l10n.continueText,
                titleSecondary: enL10n.continueText,
                isEnabled: _selectedRole != null,
                onPressed: () {
                  if (_selectedRole == 'farmer') {
                    Navigator.pushNamed(context, AppRouter.farmer);
                  } else if (_selectedRole == 'customer') {
                    Navigator.pushNamed(context, AppRouter.customer);
                  } else if (_selectedRole == 'bulk_buyer') {
                    Navigator.pushNamed(context, AppRouter.bulkBuyer);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
