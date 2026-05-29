import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  // Jika run di Android Emulator, gunakan 10.0.2.2
  // Jika run di Flutter Web / Chrome, gunakan 127.0.0.1 atau localhost
  // Jika run di HP fisik (satu WiFi), gunakan IP komputer Anda (misal: 192.168.x.x)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }
  
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
