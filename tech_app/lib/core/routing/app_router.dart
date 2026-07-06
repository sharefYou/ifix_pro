import 'package:go_router/go_router.dart';
import '../../features/onboarding/ui/screens/language_screen.dart';
import '../../features/onboarding/ui/screens/welcome_screen.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/register_screen.dart';
import '../../features/auth/ui/screens/otp_screen.dart';
import '../../features/auth/ui/screens/pending_approval_screen.dart';
import '../../features/home/ui/screens/home_screen.dart';
import '../../features/orders/ui/screens/order_details_screen.dart';
import '../../features/custom_orders/ui/screens/custom_orders_list_screen.dart';
import '../../features/custom_orders/ui/screens/submit_offer_screen.dart';
import '../../features/wallet/ui/screens/wallet_screen.dart';
import '../../features/wallet/ui/screens/upload_receipt_screen.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/analytics/ui/screens/analytics_screen.dart';
import '../../features/orders/ui/screens/order_checklist_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.language,
    routes: [
      GoRoute(
        path: AppRoutes.language,
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(phone: args['phone']?.toString() ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.pendingApproval,
        builder: (_, _) => const PendingApprovalScreen(),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.orderDetails,
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return OrderDetailsScreen(
            orderId: args['orderId'] as int? ?? 0,
            orderData: args['orderData'] as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.orderChecklist,
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return OrderChecklistScreen(
            orderId: args['orderId'] as int? ?? 0,
            serviceName: args['serviceName']?.toString() ?? 'خدمة صيانة',
            customerName: args['customerName']?.toString() ?? 'عميل',
            totalPrice: args['totalPrice'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customOrders,
        builder: (_, _) => const CustomOrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.submitOffer,
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SubmitOfferScreen(
            request: args['request'] as dynamic,
            bidId: args['bidId'] as int?,
            isCounter: args['isCounter'] as bool? ?? false,
          );
        },
      ),
      GoRoute(path: AppRoutes.wallet, builder: (_, _) => const WalletScreen()),
      GoRoute(
        path: AppRoutes.uploadReceipt,
        builder: (_, _) => const UploadReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (_, _) => const AnalyticsScreen(),
      ),
    ],
  );
}

class AppRoutes {
  AppRoutes._();

  static const String language = '/language';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String pendingApproval = '/pending-approval';
  static const String home = '/home';
  static const String orderDetails = '/order-details';
  static const String orderChecklist = '/order-checklist';
  static const String customOrders = '/custom-orders';
  static const String submitOffer = '/submit-offer';
  static const String wallet = '/wallet';
  static const String uploadReceipt = '/upload-receipt';
  static const String profile = '/profile';
  static const String analytics = '/analytics';
}

