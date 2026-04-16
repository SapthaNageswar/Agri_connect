import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<OrdersProvider>().notifications;

    return Scaffold(
      appBar: const AgriAppBar(title: 'Notifications'),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: '🔔',
              title: 'No notifications',
              subtitle: 'Your order updates and alerts will appear here',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final stamp = n['timestamp'] as dynamic;
                String timeStr = 'Just now';
                if (stamp != null) {
                  final date = (stamp as dynamic).toDate();
                  timeStr = DateFormat('MMM d, h:mm a').format(date);
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: n['read'] == true ? Colors.white : AppTheme.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primary,
                        child: Icon(
                          n['title'].toString().contains('New') ? Icons.shopping_bag : Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(n['title'] ?? 'Alert', 
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                Text(timeStr, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n['body'] ?? '', 
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
