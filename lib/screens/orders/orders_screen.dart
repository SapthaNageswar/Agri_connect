import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';
import 'package:agriconnect/screens/orders/order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : provider.orders.isEmpty
              ? const EmptyState(icon: '📦', title: 'No orders yet',
                  subtitle: 'Your placed orders will appear here')
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: provider.orders.length,
                  itemBuilder: (_, i) {
                    final o = provider.orders[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: o)),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text('ORD-${o.id.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const Spacer(),
                              StatusBadge.fromStatus(o.status),
                            ]),
                            const SizedBox(height: 8),
                            Text('${o.cropName} · ${o.quantity.toInt()} kg from ${o.location}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(children: [
                              _metaItem('Amount', '₹${o.totalAmount.toStringAsFixed(0)}'),
                              const SizedBox(width: 20),
                              _metaItem('Qty', '${o.quantity.toInt()} kg'),
                            ]),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showContactDialog(context, o.farmerMobile),
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text('Contact Farmer'),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showContactDialog(BuildContext context, String mobile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Farmer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You can reach the farmer at:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(mobile, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              // In a real app, use url_launcher: tel:$mobile
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $mobile...'))
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(String label, String value) => RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
      );
}
