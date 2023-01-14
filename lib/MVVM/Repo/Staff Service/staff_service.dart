import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Models/Staff Model/staff_model.dart';

class StaffService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<StaffModel>> getStaff(String restaurantId) {
    return _db
        .collection("/restaurants")
        .doc(restaurantId)
        .collection("staff")
        .where("restaurant_id", isEqualTo: restaurantId)
        .snapshots()
        .map((list) {
      return list.docs.map((e) {
        return StaffModel.fromFirestore(e);
      }).toList();
    });
  }



  Future<Object> createStaff(
      String name, String email, String phoneNo, String restaurantId, String restaurantName, String role, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection("/restaurants").doc(restaurantId).collection("staff").doc().set({
        "uid": cred.user?.uid ?? "",
        "name": name,
        "email": email,
        "phone_no": phoneNo,
        "assigned_restaurant": restaurantName,
        "restaurant_id": restaurantId,
        "role": role,
      });
      return Success(200, "Staff created successfully !!");
    } on FirebaseAuthException catch (e) {
      return Failure(101, e.code);
    }
  }
}
