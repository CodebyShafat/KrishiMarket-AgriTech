import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/language_provider.dart';
import '../../../../core/utils/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'privacy_security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = AppThemeNotifier.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.changeTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.changeTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.changeTheme(val!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = AppLanguage.of(context).currentLocale.languageCode;
    final enL10n = lookupAppLocalizations(const Locale('en'));
    final themeProvider = AppThemeNotifier.of(context);

    String currentThemeName = 'System';
    if (themeProvider.themeMode == ThemeMode.light) currentThemeName = 'Light';
    if (themeProvider.themeMode == ThemeMode.dark) currentThemeName = 'Dark';

    final Map<String, String> languageNames = {
      'hi': 'Hindi (हिन्दी)',
      'en': 'English',
      'bn': 'Bengali (বাংলা)',
      'mr': 'Marathi (मराठी)',
      'te': 'Telugu (తెలుగు)',
      'ta': 'Tamil (தமிழ்)',
      'gu': 'Gujarati (ગુજરાતી)',
      'kn': 'Kannada (ಕನ್ನಡ)',
      'ml': 'Malayalam (മലയാളം)',
      'pa': 'Punjabi (ਪੰਜਾਬੀ)',
      'or': 'Odia (ଓଡ଼ିଆ)',
      'as': 'Assamese (অসমীয়া)',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(l10n.settings, enL10n.settings, context),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(l10n.chooseLanguage),
                  subtitle: Text(languageNames[currentLang] ?? 'Unknown'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRouter.languageSelection),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications, color: Colors.orange),
                  title: const Text('Notifications'),
                  subtitle: const Text('Preference only. Push delivery NOT IMPLEMENTED.', style: TextStyle(color: Colors.grey)),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.color_lens, color: Colors.purple),
                  title: const Text('Theme'),
                  subtitle: Text(currentThemeName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account', 'Account', context),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.green),
                  title: const Text('Privacy & Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Clear session and return to login'),
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    try {
                      await context.read<AuthProvider>().signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.phoneAuth,
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to logout. Please try again.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String primary,
    String secondary,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(primary, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '($secondary)',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
