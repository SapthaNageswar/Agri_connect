// screens/marketplace/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/providers/marketplace_provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/models/models.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';

const _cropEmojis = {'Wheat': '🌾', 'Rice': '🌿', 'Corn': '🌽', 'Tomato': '🍅',
  'Onion': '🧅', 'Potato': '🥔', 'Coconut': '🥥', 'Soybean': '🌱', 'Cotton': '🌸'};

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _search = '';
  String? _category;
  final _categories = ['Vegetables', 'Grains', 'Fruits', 'Dairy'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();

    final filtered = provider.listings
        .where((l) {
          final matchesSearch = l.cropName.toLowerCase().contains(_search.toLowerCase());
          final matchesCat = _category == null || l.category.toLowerCase() == _category;
          return matchesSearch && matchesCat;
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Marketplace'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search crops...',
                hintStyle: const TextStyle(color: Color(0xFFB0E8BF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB0E8BF)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              children: [
                _FilterChip(label: 'All', selected: _category == null,
                    onTap: () => setState(() => _category = null)),
                ..._categories.map((c) => _FilterChip(label: c,
                    selected: _category == c.toLowerCase(),
                    onTap: () => setState(() => _category = c.toLowerCase()))),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: 4,
                    itemBuilder: (_, __) => const LoadingCard())
                : filtered.isEmpty
                    ? const EmptyState(icon: '🌾', title: 'No listings found',
                        subtitle: 'Be the first to add a crop listing')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final l = filtered[i];
                          final user = context.watch<AuthProvider>().user;
                          final isOwner = user?.uid == l.farmerId;
                          final isFarmer = user?.role == 'farmer';
                          return ListingCard(
                            listing: l,
                            isFarmer: isOwner && isFarmer,
                            cropEmoji: _cropEmojis[l.cropName] ?? '🌿',
                            onActionTap: () {
                              if (isOwner && isFarmer) {
                                _showEditDialog(context, l);
                              } else {
                                _showBuyDialog(context, l);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditListingBottomSheet(listing: listing),
    );
  }

  void _showBuyDialog(BuildContext context, listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BuyBottomSheet(listing: listing),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
          ),
          child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
          )),
        ),
      );
}

class _BuyBottomSheet extends StatefulWidget {
  final dynamic listing;
  const _BuyBottomSheet({required this.listing});

  @override
  State<_BuyBottomSheet> createState() => _BuyBottomSheetState();
}

class _BuyBottomSheetState extends State<_BuyBottomSheet> {
  double _qty = 10;

  @override
  void initState() {
    super.initState();
    if (widget.listing.quantity < _qty) {
      _qty = widget.listing.quantity.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _qty * widget.listing.pricePerUnit;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buy ${widget.listing.cropName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _qtyBtn(Icons.remove, () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('${_qty.toInt()} kg', 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.primary)),
              ),
              _qtyBtn(Icons.add, () => setState(() => _qty = _qty < widget.listing.quantity ? _qty + 1 : widget.listing.quantity)),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Total Amount:', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Text('₹${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final ok = await context.read<OrdersProvider>().placeOrder(
                listingId: widget.listing.id,
                cropName: widget.listing.cropName,
                farmerId: widget.listing.farmerId,
                farmerMobile: widget.listing.farmerMobile,
                location: widget.listing.location,
                quantity: _qty,
                totalAmount: total,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Order placed successfully!' : 'Failed to place order'),
                  backgroundColor: ok ? AppTheme.success : AppTheme.error,
                ));
              }
            },
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: onTap, 
          icon: Icon(icon, size: 20, color: AppTheme.primary),
        ),
      );
}

class _EditListingBottomSheet extends StatefulWidget {
  final ListingModel listing;
  const _EditListingBottomSheet({required this.listing});

  @override
  State<_EditListingBottomSheet> createState() => _EditListingBottomSheetState();
}

class _EditListingBottomSheetState extends State<_EditListingBottomSheet> {
  late double _qty;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _qty = widget.listing.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Edit ${widget.listing.cropName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Available Quantity:', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Text('${_qty.toInt()} ${widget.listing.unit}', 
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              _qtyBtn(Icons.remove, () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1)),
              Expanded(
                child: Slider(
                  value: _qty.clamp(1, 10000).toDouble(), // clamp for safety
                  min: 1, max: 10000, 
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _qty = v),
                ),
              ),
              _qtyBtn(Icons.add, () => setState(() => _qty = _qty + 1)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error, 
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isSaving ? null : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove Listing?'),
                        content: const Text('This will delete your crop listing from the marketplace permanently.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), 
                            child: const Text('Remove', style: TextStyle(color: AppTheme.error))),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      setState(() => _isSaving = true);
                      await context.read<MarketplaceProvider>().deleteListing(widget.listing.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Remove Listing'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _isSaving ? null : () async {
                    setState(() => _isSaving = true);
                    final ok = await context.read<MarketplaceProvider>().updateListing(widget.listing.id, {
                      'quantity': _qty,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Listing updated successfully!' : 'Failed to update listing'),
                          backgroundColor: ok ? AppTheme.success : AppTheme.error,
                        )
                      );
                    }
                  },
                  child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: onTap, 
          icon: Icon(icon, size: 20, color: AppTheme.primary),
        ),
      );
}

