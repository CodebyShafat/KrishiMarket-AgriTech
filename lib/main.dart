import 'package:flutter/material.dart';
import 'package:krishimarket/core/theme/app_theme.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/utils/language_provider.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/marketplace/data/repositories/mock_product_repository.dart';
import 'features/marketplace/data/repositories/mock_cart_repository.dart';
import 'features/marketplace/data/repositories/mock_order_repository.dart';
import 'features/marketplace/presentation/providers/product_provider.dart';
import 'features/marketplace/presentation/providers/marketplace_provider.dart';
import 'features/marketplace/presentation/providers/cart_provider.dart';
import 'features/marketplace/presentation/providers/order_provider.dart';
import 'features/marketplace/data/repositories/mock_bulk_requirement_repository.dart';
import 'features/marketplace/data/repositories/mock_bulk_offer_repository.dart';
import 'features/marketplace/presentation/providers/bulk_requirement_provider.dart';
import 'features/marketplace/presentation/providers/bulk_offer_provider.dart';

import 'features/ai_assistant/data/repositories/mock_ai_action_executor.dart';
import 'features/ai_assistant/data/repositories/mock_ai_assistant_repository.dart';
import 'features/ai_assistant/data/repositories/mock_voice_services.dart';
import 'features/ai_assistant/presentation/providers/ai_assistant_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: MockAuthRemoteDataSourceImpl(),
    localDataSource: AuthLocalDataSourceImpl(),
  );

  final productRepository = MockProductRepository();
  final cartRepository = MockCartRepository();
  final orderRepository = MockOrderRepository(productRepository);
  final bulkReqRepository = MockBulkRequirementRepository();
  final bulkOfferRepository = MockBulkOfferRepository();

  final aiActionExecutor = MockAiActionExecutor(
    productRepository: productRepository,
    cartRepository: cartRepository,
    orderRepository: orderRepository,
    bulkRequirementRepository: bulkReqRepository,
    bulkOfferRepository: bulkOfferRepository,
  );

  final aiAssistantRepository = MockAiAssistantRepository();
  final voiceInputService = MockVoiceInputService();
  final voiceOutputService = MockVoiceOutputService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketplaceProvider(productRepository),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(cartRepository)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderRepository)),
        ChangeNotifierProvider(
          create: (_) => BulkRequirementProvider(bulkReqRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              BulkOfferProvider(bulkOfferRepository, bulkReqRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AiAssistantProvider(
            assistantRepository: aiAssistantRepository,
            actionExecutor: aiActionExecutor,
            voiceInputService: voiceInputService,
            voiceOutputService: voiceOutputService,
          ),
        ),
      ],
      child: AppLanguage(
        notifier: languageProvider,
        child: const KrishiMarketApp(),
      ),
    ),
  );
}

class KrishiMarketApp extends StatelessWidget {
  const KrishiMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = AppLanguage.of(context);

    return MaterialApp(
      title: 'KrishiMarket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languageProvider.currentLocale,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
