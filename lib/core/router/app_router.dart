import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/login_page.dart';
import '../../presentation/auth/screens/register_page.dart';
import '../../presentation/auth/screens/forgot_password_page.dart';
import '../../presentation/auth/screens/otp_verification_screen.dart';
import '../../presentation/auth/screens/change_password_screen.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/prediction/screens/prediction_screen.dart';
import '../../presentation/prediction/screens/prediction_result_screen.dart';
import '../../presentation/history/screens/history_screen.dart';
import '../../presentation/articles/screens/articles_screen.dart';
import '../../presentation/articles/screens/article_detail_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/chat/screens/chat_screen.dart';

class AppRoutes {
  AppRoutes._();

  // ── Route Names ──────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String changePassword = '/change-password';
  static const String dashboard = '/dashboard';
  static const String prediction = '/prediction';
  static const String predictionResult = '/prediction/result';
  static const String history = '/history';
  static const String articles = '/articles';
  static const String articleDetail = '/articles/:id';
  static const String profile = '/profile';
  static const String chat = '/chat';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  // TODO: Add redirect logic based on auth state
  // redirect: (context, state) => authGuard(context, state),
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.otpVerification,
      name: 'otp-verification',
      builder: (context, state) =>
          OtpVerificationScreen(email: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.prediction,
      name: 'prediction',
      builder: (context, state) => const PredictionScreen(),
    ),
    GoRoute(
      path: AppRoutes.predictionResult,
      name: 'prediction-result',
      builder: (context, state) => const PredictionResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.articles,
      name: 'articles',
      builder: (context, state) => const ArticlesScreen(),
    ),
    GoRoute(
      path: AppRoutes.articleDetail,
      name: 'article-detail',
      builder: (context, state) =>
          ArticleDetailScreen(articleId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
  ),
);
