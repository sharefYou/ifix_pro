import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/bloc_observer.dart';
import 'package:ifix_client/core/helpers/cache_helper.dart';
import 'package:ifix_client/features/custom_requests/manager/custom_requests_cubit.dart';
import 'package:ifix_client/features/orders/manager/orders_cubit.dart';
import 'package:ifix_client/features/profile/manager/profile_cubit.dart';
import 'package:ifix_client/features/services/manager/services_cubit.dart';
import 'package:ifix_client/features/splash/ui/screens/splash_screen.dart';
import 'package:ifix_client/features/wallet/manager/wallet_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.initialDio();
  await CacheHelper.init();
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServicesCubit>(create: (_) => ServicesCubit()..fetchServices()),
        BlocProvider<OrdersCubit>(create: (_) => OrdersCubit()),
        BlocProvider<WalletCubit>(create: (_) => WalletCubit()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<CustomRequestsCubit>(create: (_) => CustomRequestsCubit()),
      ],
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    );
  }
}
