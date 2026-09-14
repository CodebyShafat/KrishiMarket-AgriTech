import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _businessNameController = TextEditingController();
  String? _selectedBusinessType;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if ((_formKey.currentState?.validate() ?? false) && _selectedRole != null) {
      context.read<AuthProvider>().completeProfile(
        role: _selectedRole,
        fullName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        businessName: _selectedRole == 'bulk_buyer'
            ? _businessNameController.text.trim()
            : null,
        businessType: _selectedRole == 'bulk_buyer'
            ? _selectedBusinessType
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));
    final authState = context.watch<AuthProvider>().state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == AuthState.authenticated) {
        if (_selectedRole == 'farmer') {
          Navigator.pushReplacementNamed(context, '/farmer');
        } else if (_selectedRole == 'retail_buyer') {
          Navigator.pushReplacementNamed(context, '/customer');
        } else if (_selectedRole == 'bulk_buyer') {
          Navigator.pushReplacementNamed(context, '/bulkBuyer');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.profileTitle} (${enL10n.profileTitle})'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${l10n.whoAreYou}\n(${enL10n.whoAreYou})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildRoleSelection(l10n, enL10n),
                const SizedBox(height: 24),

                if (_selectedRole != null) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n.fullNameHint} (${enL10n.fullNameHint})',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n.locationHint} (${enL10n.locationHint})',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  if (_selectedRole == 'bulk_buyer') ...[
                    TextFormField(
                      controller: _businessNameController,
                      decoration: InputDecoration(
                        labelText:
                            '${l10n.businessNameHint} (${enL10n.businessNameHint})',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText:
                            '${l10n.businessTypeHint} (${enL10n.businessTypeHint})',
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _selectedBusinessType,
                      items: [
                        DropdownMenuItem(
                          value: 'restaurant',
                          child: Text(
                            '${l10n.restaurant} (${enL10n.restaurant})',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'hotel',
                          child: Text('${l10n.hotel} (${enL10n.hotel})'),
                        ),
                        DropdownMenuItem(
                          value: 'groceryStore',
                          child: Text(
                            '${l10n.groceryStore} (${enL10n.groceryStore})',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('${l10n.other} (${enL10n.other})'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedBusinessType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (authState == AuthState.authenticating)
                    const Center(child: CircularProgressIndicator())
                  else
                    PrimaryButton(
                      titlePrimary: l10n.save,
                      titleSecondary: enL10n.save,
                      isEnabled: true,
                      onPressed: _submit,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection(AppLocalizations l10n, AppLocalizations enL10n) {
    return Row(
      children: [
        Expanded(
          child: _roleCard(
            'farmer',
            l10n.farmer,
            enL10n.farmer,
            Icons.agriculture,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _roleCard(
            'retail_buyer',
            l10n.customer,
            enL10n.customer,
            Icons.person,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _roleCard(
            'bulk_buyer',
            l10n.bulkBuyer,
            enL10n.bulkBuyer,
            Icons.store,
          ),
        ),
      ],
    );
  }

  Widget _roleCard(String role, String title, String subtitle, IconData icon) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              '($subtitle)',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
