import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:krishimarket/main.dart';
import 'package:krishimarket/core/utils/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:krishimarket/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:krishimarket/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:krishimarket/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:krishimarket/features/auth/presentation/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App full authentication flow to Farmer Home', (
    WidgetTester tester,
  ) async {
    final languageProvider = LanguageProvider();

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: MockAuthRemoteDataSourceImpl(),
      localDataSource: AuthLocalDataSourceImpl(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ],
        child: AppLanguage(
          notifier: languageProvider,
          child: const KrishiMarketApp(),
        ),
      ),
    );
    await tester.pump();

    // Splash screen -> Language selection (after 2 sec)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(); // Resolve restoreSession
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);

    // Tap Continue
    await tester.tap(find.text('आगे बढ़ें').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Transition

    // Should be at Phone Auth
    expect(find.text('साइन इन करें'), findsWidgets);

    // Enter phone
    await tester.enterText(find.byType(TextFormField), '9999999999');
    await tester.tap(find.text('आगे बढ़ें').first);

    // Simulate API delay
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // Wait for API
    await tester.pumpAndSettle(); // Wait for navigation transition

    // OTP Screen
    expect(find.text('OTP सत्यापित करें'), findsWidgets);

    // Enter 123456 in individual text fields
    final otpFields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(otpFields.at(i), (i + 1).toString());
    }

    // Wait for the automatic submission via focus change or explicit tap
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // Wait for API
    await tester.pumpAndSettle(); // Wait for navigation transition

    // Fallback: tap verify if not automatic
    if (find.text('सत्यापित करें').evaluate().isNotEmpty) {
      await tester.tap(find.text('सत्यापित करें').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    // Profile Screen
    expect(find.textContaining('प्रोफ़ाइल पूरी करें'), findsWidgets);

    // Select Farmer
    final farmerRole = find.text('किसान').first;
    await tester.dragUntilVisible(
      farmerRole,
      find.byType(SingleChildScrollView).first,
      const Offset(0, -100),
    );
    await tester.tap(farmerRole);
    await tester.pump(const Duration(seconds: 1));

    // Fill Name & Location
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Ramesh Kumar');
    await tester.enterText(textFields.at(1), 'Nashik');

    final saveFinder = find.text('सहेजें').first;
    await tester.dragUntilVisible(
      saveFinder,
      find.byType(SingleChildScrollView).first,
      const Offset(0, -200),
    );
    await tester.tap(saveFinder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // Wait for API
    await tester.pumpAndSettle(); // Wait for navigation transition

    // Verify Farmer Home Screen
    expect(find.textContaining('किसान होम'), findsWidgets);
  });
}
