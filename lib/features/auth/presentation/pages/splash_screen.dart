import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

import '../providers/auth_provider.dart';
import '../../../../core/routing/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Delay for brand visibility
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Restore session
    final authProvider = context.read<AuthProvider>();
    await authProvider.restoreSession();

    if (!mounted) return;

    final state = authProvider.state;
    if (state == AuthState.unauthenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.languageSelection);
    } else if (state == AuthState.profileIncomplete) {
      Navigator.pushReplacementNamed(context, '/profileCompletion');
    } else if (state == AuthState.authenticated) {
      final role = authProvider.currentUser?.role;
      if (role == 'farmer') {
        Navigator.pushReplacementNamed(context, '/farmer');
      } else if (role == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer');
      } else if (role == 'bulk_buyer') {
        Navigator.pushReplacementNamed(context, '/bulkBuyer');
      } else {
        Navigator.pushReplacementNamed(context, '/phoneAuth');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/phoneAuth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder logo using icon
            const Icon(Icons.agriculture, size: 120, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.displayLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              enL10n.appTitle,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: Colors.white70, letterSpacing: 2.0),
            ),
          ],
        ),
      ),
    );
  }
}
