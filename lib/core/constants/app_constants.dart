class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://10.10.181.112:8000/api';
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-domain.com/api'; // Production

  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // ── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'HeartCare';
  static const String appVersion = '1.0.0';

  // ── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;
}
