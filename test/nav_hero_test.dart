import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishimarket/features/marketplace/presentation/pages/farmer_home_screen.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/product_provider.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/auth/presentation/providers/auth_provider.dart';
import 'package:krishimarket/features/auth/domain/entities/user_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserEntity? get currentUser => UserEntity(id: 'test', phone: 'test', role: 'Farmer');
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Hero test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR: ' + details.exception.toString());
    };
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider(MockProductRepository())),
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.generateRoute,
          home: const FarmerHomeScreen(),
        ),
      )
    );
    
    await tester.pumpAndSettle();
    
    // Tap My Products
    final myProductsText = find.text('My Products');
    expect(myProductsText, findsWidgets);
    await tester.tap(myProductsText.first);
    await tester.pumpAndSettle();
    
    // Tap FAB
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    
    // We expect the transition to finish
    await tester.pumpAndSettle();
    
    print('Navigated successfully?');
  });
}
