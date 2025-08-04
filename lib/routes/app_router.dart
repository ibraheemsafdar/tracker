
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ category/view/category_screen.dart';
import '../add_transaction/view/add_transaction_screen.dart';
import '../analytics/view/analytics_screen.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../dashboard/view/profile_screen.dart';
import '../forgot_password/view/forgot_password_screen.dart';
import '../login/view/login_screen.dart';
import '../signup/view/signup_screen.dart';
import '../spending_goal/view/SpendingGoalsScreen.dart';
import '../splash/view/splash_screen.dart';
import '../transaction_history/view/transaction_history_screen.dart';
import '../welcome/view/welcome_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/spending-goals',
        builder: (context, state) => const SpendingGoalsScreen(),
      ),
    ],
  );
});
