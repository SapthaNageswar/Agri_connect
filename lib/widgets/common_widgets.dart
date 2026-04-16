// widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/models/models.dart';

// ── Green header app bar ──────────────────────────────────────────────────
class AgriAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  const AgriAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBack,
        actions: actions,
      );
}

// ── Section label ─────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary, letterSpacing: 0.8,
          ),
        ),
      );
}

// ── Status badge ──────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const StatusBadge({super.key, required this.label, required this.bg, required this.fg});

  static StatusBadge fromStatus(String status) {
    switch (status) {
      case 'delivered':
        return StatusBadge(label: 'Delivered', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534));
      case 'ordered':
        return StatusBadge(label: 'Ordered', bg: const Color(0xFFFFEDD5), fg: const Color(0xFF9A3412));
      case 'in_transit':
        return StatusBadge(label: 'In Transit', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E));
      case 'confirmed':
        return StatusBadge(label: 'Confirmed', bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E3A8A));
      default:
        return StatusBadge(label: 'Pending', bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B));
    }
  }

  static StatusBadge fromTrend(String trend, double change) {
    if (trend == 'up') return StatusBadge(label: '↑ +${change.toStringAsFixed(0)}%', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534));
    if (trend == 'down') return StatusBadge(label: '↓ ${change.toStringAsFixed(0)}%', bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B));
    return StatusBadge(label: '→ Stable', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E));
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );
}

// ── Stat card (summary numbers) ───────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.value, required this.label, this.valueColor, this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    color: valueColor ?? Colors.white)),
                const SizedBox(height: 3),
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFC8F5CC))),
              ],
            ),
          ),
        ),
      );
}

// ── Listing card ──────────────────────────────────────────────────────────
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onActionTap;
  final String cropEmoji;
  final bool isFarmer;

  const ListingCard({
    super.key,
    required this.listing,
    this.onActionTap,
    this.cropEmoji = '🌾',
    this.isFarmer = false,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72, height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(cropEmoji, style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.cropName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Row(children: [
                          const Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 2),
                          Text(listing.location, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Quantity', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            Text('${listing.quantity.toInt()} ${listing.unit}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(width: 24),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Price/kg', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            Text('₹${listing.pricePerUnit.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          ]),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onActionTap,
                      icon: Icon(isFarmer ? Icons.edit : Icons.add, size: 18),
                      label: Text(isFarmer ? 'Edit' : 'Buy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(listing.cropName),
                                content: Text(
                                    'Category: ${listing.category}\nFarmer ID: ${listing.farmerId}\nLocation: ${listing.location}\nQuantity Available: ${listing.quantity.toInt()} ${listing.unit}\nPrice: ₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}\nDescription: ${listing.description.isEmpty ? "No description provided." : listing.description}'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                                ],
                              ),
                            );
                          },
                          child: const Text('View Details'))),
                ],
              ),
            ],
          ),
        ),
      );
}

// ── Loading shimmer ───────────────────────────────────────────────────────
class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );
}
