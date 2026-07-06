import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/data/repos/auth_repo.dart';
import 'features/orders/logic/order_cubit.dart';
import 'features/orders/data/repos/order_repo.dart';
import 'features/custom_orders/logic/custom_orders_cubit.dart';
import 'features/custom_orders/data/repos/custom_orders_repo.dart';
import 'features/analytics/logic/analytics_cubit.dart';
import 'features/analytics/data/repos/analytics_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D1117),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const IFixTechApp(),
    ),
  );
}

class IFixTechApp extends StatelessWidget {
  const IFixTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(AuthRepository())),
        BlocProvider(create: (context) => OrderCubit(OrderRepository())..getAvailableOrders()),
        BlocProvider(create: (context) => CustomOrdersCubit(CustomOrdersRepository())..loadData()),
        BlocProvider(create: (context) => AnalyticsCubit(AnalyticsRepo())),
      ],
      child: MaterialApp.router(
        title: 'iFix-Tech',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        builder: (context, child) {
          return Directionality(
            textDirection: context.locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          );
        },
      ),
    );
  }
}
