import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _submit();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _submit() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      context.read<AuthProvider>().verifyOtp(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));
    final authProvider = context.watch<AuthProvider>();
    final authState = authProvider.state;
    final error = authProvider.error;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == AuthState.profileIncomplete) {
        Navigator.pushReplacementNamed(context, '/profileCompletion');
      } else if (authState == AuthState.authenticated) {
        // Will route to correct dashboard in next step, normally splash or central router does this
        // But for direct nav, we check role:
        final role = authProvider.currentUser?.role;
        if (role == 'farmer') {
          Navigator.pushReplacementNamed(context, '/farmer');
        } else if (role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customer');
        } else if (role == 'bulk_buyer') {
          Navigator.pushReplacementNamed(context, '/bulkBuyer');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.otpTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.otpSubtitle}\n(${enL10n.otpSubtitle})',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.currentPhone ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Mock Info
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.amber.shade100,
                child: const Text(
                  'DEVELOPMENT MOCK: Use OTP 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              if (authState == AuthState.authenticating)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  titlePrimary: l10n.verifyBtn,
                  titleSecondary: enL10n.verifyBtn,
                  isEnabled: true,
                  onPressed: _submit,
                ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().signInWithPhone(
                    authProvider.currentPhone ?? '',
                  );
                },
                child: Text('${l10n.resendOtp} (${enL10n.resendOtp})'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String key, AppLocalizations l10n) {
    switch (key) {
      case 'invalidOtp':
        return l10n.invalidOtp;
      case 'otpExpired':
        return l10n.otpExpired;
      case 'tooManyAttempts':
        return l10n.tooManyAttempts;
      case 'networkError':
        return l10n.networkError;
      default:
        return l10n.unknownError;
    }
  }
}
