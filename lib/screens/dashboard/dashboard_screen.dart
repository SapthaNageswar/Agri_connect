// screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/providers/marketplace_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';
import 'package:agriconnect/services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchMyOrders();
      context.read<MarketplaceProvider>().fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final orders = context.watch<OrdersProvider>().orders;
    final marketListings = context.watch<MarketplaceProvider>().listings;

    final isFarmer = (user?.role ?? '').toLowerCase() == 'farmer';
    final relevantOrders = orders.where((o) => isFarmer ? o.farmerId == user?.uid : o.buyerId == user?.uid).toList();

    final activeOrders = relevantOrders.where((o) => o.status != 'delivered').length;
    final rev = relevantOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);
    final revStr = rev >= 1000 ? '₹${(rev/1000).toStringAsFixed(1)}K' : '₹${rev.toStringAsFixed(0)}';
    final revLabel = isFarmer ? 'Revenue' : 'Spent';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Green header
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.primary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 18, right: 18, bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.white, size: 24),
                      const Spacer(),
                      Row(children: [
                        const Icon(Icons.eco, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        const Text('AgriConnect',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Welcome back,',
                      style: TextStyle(color: Color(0xFFC8F5CC), fontSize: 13)),
                  Text(user?.name ?? 'Farmer',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick access removed to use BottomNavigationBar

                // Today's summary
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Summary",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(children: [
                        StatCard(
                          value: '$activeOrders', 
                          label: 'Active Orders',
                          onTap: () => context.push('/orders'),
                        ),
                        const SizedBox(width: 10),
                        StatCard(value: revStr, label: revLabel, onTap: () {}),
                        const SizedBox(width: 10),
                        const StatCard(value: '98%', label: 'Quality Score'),
                      ]),
                    ],
                  ),
                ),

                // Notification Activation
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.notifications_active, color: AppTheme.primary, size: 20),
                    ),
                    title: const Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Get alerts for order updates and price changes', style: TextStyle(fontSize: 11)),
                    trailing: Switch(
                      value: true, // Mock value
                      onChanged: (v) {
                        NotificationService.showManualNotification(
                          'Notifications Enabled', 
                          'You will now receive all agricultural alerts and order updates'
                        );
                      },
                      activeColor: AppTheme.primary,
                    ),
                  ),
                ),

                // Market horizontal slide
                if (marketListings.isNotEmpty) ...[
                  const SectionLabel('Marketplace Highlights'),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: marketListings.length,
                      itemBuilder: (context, index) {
                        final l = marketListings[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 14),
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 70,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(child: Icon(Icons.eco, color: AppTheme.primary, size: 32)),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(l.cropName, 
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(l.location, 
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('₹${l.pricePerUnit.toStringAsFixed(0)}/${l.unit}',
                                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 13)),
                                      const StatusBadge(label: 'New', bg: Color(0xFFDCFCE7), fg: Color(0xFF166534)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
