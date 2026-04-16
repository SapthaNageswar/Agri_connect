import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agriconnect/models/models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _firebaseUser != null;
  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _firebaseUser = user;
      if (user != null) await _loadUserProfile(user.uid);
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) _userModel = UserModel.fromMap(doc.data()!);
  }

  Future<bool> register({
    required String name,
    required String mobile,
    required String password,
    String role = 'farmer',
    String city = '',
    String state = '',
    String location = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final email = '$mobile@agriconnect.app';
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user!.updateDisplayName(name);
      final userModel = UserModel(
        uid: cred.user!.uid,
        name: name,
        mobile: mobile,
        role: role,
        city: city,
        state: state,
        location: location,
      );
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set({...userModel.toMap(), 'createdAt': FieldValue.serverTimestamp()});
      _userModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile() async {
    if (_firebaseUser != null) {
      await _loadUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<bool> login({required String mobile, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final email = '$mobile@agriconnect.app';
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}
