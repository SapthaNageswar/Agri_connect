// orders_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriconnect/models/models.dart';
import 'package:agriconnect/services/notification_service.dart';

class OrdersProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  final List<StreamSubscription> _roleSubs = [];

  List<OrderModel> get orders => _orders;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  OrdersProvider() {
    _listenToOrders();
    _listenToNotifications();
  }

  @override
  void dispose() {
    for (var s in _roleSubs) {
      s.cancel();
    }
    super.dispose();
  }

  void _listenToOrders() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      for (var s in _roleSubs) {
        s.cancel();
      }
      _roleSubs.clear();

      if (user == null) {
        _orders = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final buyerStream = _db.collection('orders').where('buyerId', isEqualTo: user.uid).snapshots();
      final farmerStream = _db.collection('orders').where('farmerId', isEqualTo: user.uid).snapshots();

      Map<String, OrderModel> buyerMap = {};
      Map<String, OrderModel> farmerMap = {};

      void update() {
        final all = {...buyerMap, ...farmerMap}.values.toList();
        all.sort((a, b) {
          if (a.createdAt == null) return -1;
          if (b.createdAt == null) return 1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _orders = all;
        _isLoading = false;
        notifyListeners();
      }

      _roleSubs.add(buyerStream.listen((snap) {
        buyerMap = { for (var d in snap.docs) d.id : OrderModel.fromMap(d.id, d.data()) };
        update();
      }));
      
      _roleSubs.add(farmerStream.listen((snap) {
        farmerMap = { for (var d in snap.docs) d.id : OrderModel.fromMap(d.id, d.data()) };
        update();
      }));
    });
  }

  void _listenToNotifications() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _notifications = [];
        notifyListeners();
        return;
      }

      _db.collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
          _notifications = snap.docs.map((d) => {
            ...d.data(),
            'id': d.id,
          }).toList();
          notifyListeners();
        }, onError: (e) {
          // Fallback if no index yet
          _db.collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots()
            .listen((snap) {
              _notifications = snap.docs.map((d) => {
                ...d.data(),
                'id': d.id,
              }).toList();
              notifyListeners();
            });
        });
    });
  }

  // Backward compatibility method
  Future<void> fetchMyOrders() async {
    // Already handled by real-time streams
  }

  Future<bool> placeOrder({
    required String listingId,
    required String cropName,
    required String farmerId,
    required String farmerMobile,
    required String location,
    required double quantity,
    required double totalAmount,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      
      // 1. Reduce quantity from listing
      final listingDoc = await _db.collection('listings').doc(listingId).get();
      if (listingDoc.exists) {
        final currentQty = (listingDoc.data()?['quantity'] ?? 0.0).toDouble();
        await _db.collection('listings').doc(listingId).update({
          'quantity': currentQty - quantity,
        });
      }

      // 2. Add Order record
      await _db.collection('orders').add({
        'listingId': listingId,
        'cropName': cropName,
        'farmerId': farmerId,
        'farmerMobile': farmerMobile,
        'buyerId': uid,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'location': location,
        'status': 'pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Record notifications for buyer and farmer
      await _addNotification(uid, 'Success', 'You have ordered $cropName (${quantity.toInt()}kg)');
      await _addNotification(farmerId, 'New Order', 'Please confirm the order for $cropName');

      // 4. Trigger local notification for buyer
      NotificationService.showManualNotification('Order Success', 'You have ordered $cropName');

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _addNotification(String userId, String title, String body) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
    
    // Add status update notification
    final orderDoc = await _db.collection('orders').doc(orderId).get();
    if (orderDoc.exists) {
      final buyerId = orderDoc.data()?['buyerId'];
      final cropName = orderDoc.data()?['cropName'];
      if (buyerId != null) {
        await _addNotification(buyerId, 'Order Update', 'Your order for $cropName is $status');
        NotificationService.showManualNotification('Order Update', 'Your order for $cropName is $status');
      }
    }
  }
}
