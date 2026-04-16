import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isFarmer = (user?.role ?? '').toLowerCase() == 'farmer';

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Market'),
          BottomNavigationBarItem(
            icon: Icon(
              isFarmer ? Icons.add_circle : Icons.shopping_bag,
              size: 32,
              color: AppTheme.primary,
            ),
            label: isFarmer ? 'Add' : 'Orders',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Trends'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
