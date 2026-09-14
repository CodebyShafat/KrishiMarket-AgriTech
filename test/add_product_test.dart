import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishimarket/features/marketplace/presentation/pages/add_product_screen.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/product_provider.dart';
import 'package:krishimarket/features/marketplace/domain/entities/product_entity.dart';
import 'package:krishimarket/features/auth/presentation/providers/auth_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

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

void main() {
  testWidgets('Test AddProductScreen', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR: ' + details.exception.toString());
    };
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>(create: (_) => MockProductProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AddProductScreen(),
        ),
      )
    );
  });
}
