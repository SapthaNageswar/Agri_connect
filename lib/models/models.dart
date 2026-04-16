import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String role; // "farmer" | "buyer"
  final String city;
  final String state;
  final String location;
  final String language;
  final bool verified;
  final String fcmToken;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    this.role = 'farmer',
    this.city = '',
    this.state = '',
    this.location = '',
    this.language = 'en',
    this.verified = false,
    this.fcmToken = '',
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        mobile: map['mobile'] ?? '',
        role: map['role'] ?? 'farmer',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        location: map['location'] ?? '',
        language: map['language'] ?? 'en',
        verified: map['verified'] ?? false,
        fcmToken: map['fcmToken'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'role': role,
        'city': city,
        'state': state,
        'location': location,
        'language': language,
        'verified': verified,
        'fcmToken': fcmToken,
      };
}

class ListingModel {
  final String id;
  final String farmerId;
  final String farmerMobile;
  final String cropName;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String location;
  final String description;
  final String imageUrl;
  final String status;

  ListingModel({
    required this.id,
    required this.farmerId,
    required this.farmerMobile,
    required this.cropName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.location,
    this.description = '',
    this.imageUrl = '',
    this.status = 'active',
  });

  factory ListingModel.fromMap(String id, Map<String, dynamic> map) => ListingModel(
        id: id,
        farmerId: map['farmerId'] ?? '',
        farmerMobile: map['farmerMobile'] ?? '',
        cropName: map['cropName'] ?? '',
        category: map['category'] ?? '',
        quantity: (map['quantity'] ?? 0).toDouble(),
        unit: map['unit'] ?? 'kg',
        pricePerUnit: (map['pricePerUnit'] ?? 0).toDouble(),
        location: map['location'] ?? '',
        description: map['description'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        status: map['status'] ?? 'active',
      );
}

class OrderModel {
  final String id;
  final String listingId;
  final String cropName;
  final String farmerId;
  final String farmerMobile;
  final String buyerId;
  final double quantity;
  final double totalAmount;
  final String status;
  final String location;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.listingId,
    required this.cropName,
    required this.farmerId,
    required this.farmerMobile,
    required this.buyerId,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.location,
    this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? created;
    if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    }
    return OrderModel(
      id: id,
      listingId: map['listingId'] ?? '',
      cropName: map['cropName'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerMobile: map['farmerMobile'] ?? '',
      buyerId: map['buyerId'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      location: map['location'] ?? '',
      createdAt: created,
    );
  }
}

class PriceModel {
  final String id;
  final String crop;
  final String market;
  final double pricePerKg;
  final double change;
  final String trend;

  PriceModel({
    required this.id,
    required this.crop,
    required this.market,
    required this.pricePerKg,
    required this.change,
    required this.trend,
  });

  factory PriceModel.fromMap(String id, Map<String, dynamic> map) => PriceModel(
        id: id,
        crop: map['crop'] ?? '',
        market: map['market'] ?? '',
        pricePerKg: (map['pricePerKg'] ?? 0).toDouble(),
        change: (map['change'] ?? 0).toDouble(),
        trend: map['trend'] ?? 'stable',
      );
}
