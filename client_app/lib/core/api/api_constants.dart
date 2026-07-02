class ApiConstants {
  static const String baseURL = 'https://sharef.alwaysdata.net';

  // Auth Endpoints
  static const String login = '/api/v1/customer/login';
  static const String register = '/api/v1/customer/register';
  static const String verifyOtp = '/api/v1/customer/verify-otp';
  static const String resendOtp = '/api/v1/customer/resend-otp';
  static const String forgotPassword = '/api/v1/customer/forgot-password';
  static const String verifyResetPasswordOTPCode = '/api/v1/customer/verify-reset-code';
  static const String resetPassword = '/api/v1/customer/reset-password';
  static const String logout = '/api/v1/customer/logout';

  // Services Endpoints
  static const String services = '/api/v1/customer/services';
  static const String searchServices = '/api/v1/customer/services/search';

  // Profile Endpoints
  static const String profile = '/api/v1/customer/profile';

  // Wallet Endpoints
  static const String walletBalance = '/api/v1/customer/wallet/balance';
  static const String walletTransactions = '/api/v1/customer/wallet/transactions';
  static const String walletTopUp = '/api/v1/customer/wallet/top-up';

  // Orders Endpoints
  static const String orders = '/api/v1/customer/orders';
  static String acceptTechnician(int orderId) => '/api/v1/customer/orders/$orderId/accept';
  static String completeOrder(int orderId) => '/api/v1/customer/orders/$orderId/complete';
  static String cancelOrder(int orderId) => '/api/v1/customer/orders/$orderId/cancel';
  static String addReview(int orderId) => '/api/v1/customer/orders/$orderId/reviews';

  // Custom Requests Endpoints
  static const String customRequests = '/api/v1/customer/custom-requests';
  static String customRequestBids(int id) => '/api/v1/customer/custom-requests/$id/bids';
  static String acceptBid(int reqId, int bidId) => '/api/v1/customer/custom-requests/$reqId/bids/$bidId/accept';

  // General Endpoints
  static const String cities = '/api/v1/general/cities';
  static const String faqs = '/api/v1/general/faqs';
  static const String contactUs = '/api/v1/general/contact-us';
}
