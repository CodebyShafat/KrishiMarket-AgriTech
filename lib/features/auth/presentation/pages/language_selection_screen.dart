import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/language_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/selection_card.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'native': 'हिंदी', 'english': 'Hindi'},
    {'code': 'en', 'native': 'English', 'english': 'English'},
    {'code': 'bn', 'native': 'বাংলা', 'english': 'Bengali'},
    {'code': 'mr', 'native': 'मराठी', 'english': 'Marathi'},
    {'code': 'te', 'native': 'తెలుగు', 'english': 'Telugu'},
    {'code': 'ta', 'native': 'தமிழ்', 'english': 'Tamil'},
    {'code': 'gu', 'native': 'ગુજરાતી', 'english': 'Gujarati'},
    {'code': 'kn', 'native': 'ಕನ್ನಡ', 'english': 'Kannada'},
    {'code': 'ml', 'native': 'മലയാളം', 'english': 'Malayalam'},
    {'code': 'pa', 'native': 'ਪੰਜਾਬੀ', 'english': 'Punjabi'},
    {'code': 'or', 'native': 'ଓଡ଼ିଆ', 'english': 'Odia'},
    {'code': 'as', 'native': 'অসমীয়া', 'english': 'Assamese'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enL10n = lookupAppLocalizations(const Locale('en'));
    final currentLanguageCode = AppLanguage.of(context)
        .currentLocale
        .languageCode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.chooseLanguage,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '(${enL10n.chooseLanguage})',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return SelectionCard(
                      titlePrimary: lang['native']!,
                      titleSecondary: lang['english']!,
                      icon: Icons.language,
                      isSelected: currentLanguageCode == lang['code'],
                      onTap: () {
                        AppLanguage.of(context).changeLanguage(lang['code']!);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                titlePrimary: l10n.continueText,
                titleSecondary: enL10n.continueText,
                isEnabled: true,
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.phoneAuth);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
