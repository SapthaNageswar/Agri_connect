// ─── marketplace_provider.dart ────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriconnect/models/models.dart';

class MarketplaceProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<ListingModel> _listings = [];
  bool _isLoading = false;
  String? _error;
  
  // Stream subscription to handle real-time updates
  MarketplaceProvider() {
    _initListingStream();
  }

  void _initListingStream() {
    _isLoading = true;
    _db.collection('listings')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .listen((snap) {
        _listings = snap.docs
            .map((d) => ListingModel.fromMap(d.id, d.data()))
            .toList();
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
  }

  List<ListingModel> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Placeholder for manual re-fetch if needed
  Future<void> fetchListings() async {
    // Current data is handled by stream, but keeping method signature for compatibility
  }

  Future<bool> addListing(Map<String, dynamic> data) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await _db.collection('users').doc(uid).get();
      final farmerMobile = userDoc.data()?['mobile'] ?? '';
      
      await _db.collection('listings').add({
        ...data,
        'farmerId': uid,
        'farmerMobile': farmerMobile,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Stream updates automatically!
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _db.collection('listings').doc(id).delete();
      // Stream will update UI automatically as document is gone
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('listings').doc(id).update(data);
      // Stream will update UI automatically
      return true;
    } catch (e) {
      return false;
    }
  }
}

