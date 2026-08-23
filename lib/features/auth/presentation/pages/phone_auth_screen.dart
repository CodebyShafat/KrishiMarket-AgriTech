import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().signInWithPhone(
        '+91${_phoneController.text.trim()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));
    final authState = context.watch<AuthProvider>().state;
    final error = context.watch<AuthProvider>().error;

    // Handle routing based on state change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == AuthState.awaitingOtp) {
        Navigator.pushNamed(context, '/otp');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  l10n.phoneAuthTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '(${enL10n.phoneAuthTitle})',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.phoneAuthSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '(${enL10n.phoneAuthSubtitle})',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_getErrorMessage(error.messageKey, l10n)}\n(${_getErrorMessage(error.messageKey, enL10n)})',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText:
                              '${l10n.phoneNumberHint}\n(${enL10n.phoneNumberHint})',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return '${l10n.invalidPhone} (${enL10n.invalidPhone})';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                            return '${l10n.invalidPhone} (${enL10n.invalidPhone})';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                Text(
                  '${l10n.termsAccept}\n(${enL10n.termsAccept})',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                if (authState == AuthState.authenticating)
                  const Center(child: CircularProgressIndicator())
                else
                  PrimaryButton(
                    titlePrimary: l10n.continueBtn,
                    titleSecondary: enL10n.continueBtn,
                    isEnabled: true,
                    onPressed: _submit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String key, AppLocalizations l10n) {
    switch (key) {
      case 'invalidPhone':
        return l10n.invalidPhone;
      case 'networkError':
        return l10n.networkError;
      default:
        return l10n.unknownError;
    }
  }
}
