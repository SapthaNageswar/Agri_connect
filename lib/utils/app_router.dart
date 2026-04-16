import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/screens/auth/login_screen.dart';
import 'package:agriconnect/screens/auth/register_screen.dart';
import 'package:agriconnect/screens/dashboard/dashboard_screen.dart';
import 'package:agriconnect/screens/marketplace/marketplace_screen.dart';
import 'package:agriconnect/screens/marketplace/add_listing_screen.dart';
import 'package:agriconnect/screens/advisory/advisory_screen.dart';
import 'package:agriconnect/screens/orders/orders_screen.dart';
import 'package:agriconnect/screens/trends/price_trends_screen.dart';
import 'package:agriconnect/screens/profile/profile_screen.dart';
import 'package:agriconnect/screens/notifications/notifications_screen.dart';
import 'package:agriconnect/screens/main_layout.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) => GoRouter(
        initialLocation: '/login',
        refreshListenable: auth,
        redirect: (context, state) {
          final isLoggedIn = auth.isLoggedIn;
          final isAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          if (!isLoggedIn && !isAuthRoute) return '/login';
          if (isLoggedIn && isAuthRoute) return '/dashboard';
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
          GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainLayout(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/action', builder: (_, __) => const _DynamicActionScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/trends', builder: (_, __) => const PriceTrendsScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())
              ]),
            ],
          ),
          // Keep these for explicit pushing if still referenced somewhere
          GoRoute(path: '/marketplace/add', builder: (_, __) => const AddListingScreen()),
          GoRoute(path: '/advisory', builder: (_, __) => const AdvisoryScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      );
}

class _DynamicActionScreen extends StatelessWidget {
  const _DynamicActionScreen();
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isFarmer = (user?.role ?? '').toLowerCase() == 'farmer';
    return isFarmer ? const AddListingScreen() : const OrdersScreen();
  }
}

