import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';
import '../../Models/Admin Model/admin_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<AdminModel>> getAdmin(String restaurantId) {
    return _db
        .collection("/admins")
        .where("restaurant_id", isEqualTo: restaurantId)
        .snapshots()
        .map((list) {
      return list.docs.map((e) {
        return AdminModel.fromFirestore(e);
      }).toList();
    });
  }

  Future<Object> createAdmin(String name, String email, String password,
      String restaurantName, String restaurantId) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _db.collection("/admins").doc().set({
        "uid": cred.user?.uid ?? "",
        "name": name,
        "email": email,
        "assigned_restaurant": restaurantName,
        "restaurant_id": restaurantId,
        "role": "restaurant_admin",
      });
      return Success(200, "Admin created successfully !!");
    } on FirebaseAuthException catch (e) {
      return Failure(101, e.code);
    }
  }
}
