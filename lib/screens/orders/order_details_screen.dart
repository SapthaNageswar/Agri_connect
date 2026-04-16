import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/models/models.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';
import 'package:agriconnect/services/notification_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isFarmer = user?.uid == order.farmerId;

    return Scaffold(
      appBar: AgriAppBar(title: 'Order Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Text('ORD-${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const Spacer(),
                StatusBadge.fromStatus(order.status),
              ],
            ),
            const SizedBox(height: 24),

            // Crop details
            _section('Order Items'),
            _detailRow(Icons.eco, 'Crop', order.cropName),
            _detailRow(Icons.scale, 'Quantity', '${order.quantity.toInt()} kg'),
            _detailRow(Icons.payments, 'Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
            const Divider(height: 40),

            // Delivery details
            _section('Delivery Information'),
            _detailRow(Icons.location_on, 'Location', order.location),
            _detailRow(Icons.person, isFarmer ? 'Buyer ID' : 'Farmer ID', 
              isFarmer ? order.buyerId : order.farmerId),
            _detailRow(Icons.phone, 'Contact', order.farmerMobile), // In a real app, buyer mobile would also be here
            
            const SizedBox(height: 40),

            // Actions for Farmer
            if (isFarmer && order.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _handleStatusChange(context, 'rejected'),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => _handleStatusChange(context, 'confirmed'),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            
            if (isFarmer && order.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                  onPressed: () => _handleStatusChange(context, 'ordered'),
                  child: const Text('Ordered'),
                ),
              ),
            
            if (isFarmer && order.status == 'ordered')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => _handleStatusChange(context, 'delivered'),
                  child: const Text('Delivered'),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Notification Button
            if (order.status != 'delivered')
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    NotificationService.showManualNotification(
                      'Notifications Active', 
                      'You will receive updates for Order ${order.id.substring(0, 6)}'
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications enabled for this order'))
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Activate Notifications'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleStatusChange(BuildContext context, String status) async {
    await context.read<OrdersProvider>().updateStatus(order.id, status);
    
    String msg = '';
    if (status == 'confirmed') msg = 'Your order is accepted!';
    if (status == 'rejected') msg = 'Your order is rejected.';
    if (status == 'ordered') msg = 'Your order is ordered and on the way!';
    if (status == 'delivered') msg = 'Your order is delivered successfully!';
    
    if (msg.isNotEmpty) {
      NotificationService.showManualNotification('Order Update', msg);
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status'), backgroundColor: AppTheme.primary)
      );
    }
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}
