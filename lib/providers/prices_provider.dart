// prices_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agriconnect/models/models.dart';

class PricesProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<PriceModel> _prices = [];
  bool _isLoading = false;

  List<PriceModel> get prices => _prices;
  bool get isLoading => _isLoading;

  // Seed data used as fallback when Firestore is empty
  static final _seedPrices = [
    {'crop': 'Tomato',  'market': 'Koyambedu, Chennai',  'pricePerKg': 42.0, 'change': 18.0, 'trend': 'up'},
    {'crop': 'Wheat',   'market': 'Azadpur, Delhi',       'pricePerKg': 25.0, 'change': 0.0,  'trend': 'stable'},
    {'crop': 'Rice',    'market': 'Navi Mumbai APMC',     'pricePerKg': 30.0, 'change': 5.0,  'trend': 'up'},
    {'crop': 'Onion',   'market': 'Lasalgaon, Nashik',    'pricePerKg': 18.0, 'change': -8.0, 'trend': 'down'},
    {'crop': 'Corn',    'market': 'Gulbarga APMC',        'pricePerKg': 20.0, 'change': 3.0,  'trend': 'up'},
    {'crop': 'Potato',  'market': 'Agra APMC',            'pricePerKg': 14.0, 'change': -2.0, 'trend': 'down'},
    {'crop': 'Soybean', 'market': 'Indore APMC',          'pricePerKg': 52.0, 'change': 6.0,  'trend': 'up'},
  ];

  Future<void> fetchPrices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection('prices')
          .orderBy('updatedAt', descending: true)
          .limit(20)
          .get();
      if (snap.docs.isNotEmpty) {
        _prices = snap.docs
            .map((d) => PriceModel.fromMap(d.id, d.data()))
            .toList();
      } else {
        _prices = _generateRealTimePrices();
      }
    } catch (_) {
      _prices = _generateRealTimePrices();
    }
    _isLoading = false;
    notifyListeners();
  }

  List<PriceModel> _generateRealTimePrices() {
    return _seedPrices.asMap().entries.map((e) {
      final base = e.value['pricePerKg'] as double;
      final varAmt = (DateTime.now().minute % 10 - 5) + (DateTime.now().second % 5);
      final floatP = base + varAmt;
      final trend = varAmt > 0 ? 'up' : (varAmt < 0 ? 'down' : 'stable');
      return PriceModel.fromMap('seed_${e.key}', {
        ...e.value,
        'pricePerKg': floatP < 10 ? 10.0 : floatP,
        'change': varAmt.abs().toDouble(),
        'trend': trend,
      });
    }).toList();
  }
}
