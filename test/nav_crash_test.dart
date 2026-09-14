import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishimarket/features/marketplace/presentation/pages/my_products_screen.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/product_provider.dart';
import 'package:krishimarket/features/marketplace/domain/entities/product_entity.dart';
import 'package:krishimarket/features/auth/presentation/providers/auth_provider.dart';
import 'package:krishimarket/features/auth/domain/entities/user_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

class MockProductProvider extends ChangeNotifier implements ProductProvider {
  @override
  bool get isLoading => false;
  
  @override
  Future<void> addProduct(ProductEntity product) async {}
  @override
  Future<void> deleteProduct(String productId) async {}
  @override
  String? get error => null;
  @override
  Future<void> loadFarmerProducts(String farmerId) async {}
  @override
  List<ProductEntity> get products => [];
  @override
  Future<void> toggleAvailability(String productId) async {}
  @override
  Future<void> updateProduct(ProductEntity product) async {}
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserEntity? get currentUser => UserEntity(id: 'test', phone: 'test', role: 'Farmer');
  // stub others if needed
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Test MyProductsScreen to AddProduct navigation', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR: ' + details.exception.toString());
    };
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>(create: (_) => MockProductProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.generateRoute,
          home: const MyProductsScreen(),
        ),
      )
    );
    
    await tester.pumpAndSettle();
    
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    
    await tester.tap(fab);
    await tester.pumpAndSettle();
    
    print('Navigated successfully?');
  });
}
