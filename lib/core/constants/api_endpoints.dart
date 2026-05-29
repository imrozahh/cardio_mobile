class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String refresh = '/refresh';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-token';
  static const String resetPassword = '/reset-password';

  // ── Prediction ───────────────────────────────────────────────────────────
  static const String predict = '/predict';
  static const String predictionHistory = '/predictions';
  static String predictionDetail(String id) => '/predictions/$id';

  // ── Articles ─────────────────────────────────────────────────────────────
  static const String articles = '/articles';
  static String articleDetail(String id) => '/articles/$id';

  // ── Profile ──────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String changePassword = '/profile/change-password';

  // ── Dashboard ────────────────────────────────────────────────────────────
  static const String dashboardStats = '/dashboard/stats';

  // ── AI Consultation ──────────────────────────────────────────────────────
  static const String chats = '/chats';
  static const String sendChat = '/chat';
}
