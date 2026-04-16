// screens/marketplace/add_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/marketplace_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});
  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  String _category = 'vegetables';
  String _unit = 'kg';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<MarketplaceProvider>().addListing({
      'cropName': _cropCtrl.text.trim(),
      'category': _category,
      'quantity': double.parse(_qtyCtrl.text),
      'unit': _unit,
      'pricePerUnit': double.parse(_priceCtrl.text),
      'location': _locCtrl.text.trim(),
    });
    if (mounted) {
      if (ok) context.go('/dashboard');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Listing added!' : 'Failed to add listing'),
        backgroundColor: ok ? AppTheme.success : AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Crop Name'),
            TextFormField(controller: _cropCtrl, decoration: const InputDecoration(hintText: 'e.g. Tomato'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            _lbl('Category'),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(),
              items: ['vegetables', 'grains', 'fruits', 'dairy']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _lbl('Quantity'),
                TextFormField(controller: _qtyCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '500'),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _lbl('Unit'),
                DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: const InputDecoration(),
                  items: ['kg', 'ton', 'unit'].map((u) =>
                      DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ])),
            ]),
            const SizedBox(height: 14),
            _lbl('Price per $_unit (₹)'),
            TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'e.g. 25', prefixText: '₹ '),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            _lbl('Location'),
            TextFormField(controller: _locCtrl, decoration: const InputDecoration(hintText: 'Village, District, State'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            Consumer<MarketplaceProvider>(
              builder: (_, p, __) => ElevatedButton(
                onPressed: p.isLoading ? null : _submit,
                child: p.isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Post Listing'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)));
}
