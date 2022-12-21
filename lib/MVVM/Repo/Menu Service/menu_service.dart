import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class MenuService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<MenuCategoryModel>> getMenu(String restaurantId) {
    return restaurantId.isEmpty
        ? _db.collection("/menu").snapshots().map((list) {
            return list.docs.map((e) {
              return MenuCategoryModel.fromFirestore(e);
            }).toList();
          })
        : _db
            .collection("/menu")
            .where(
              "restaurant_id",
              isEqualTo: restaurantId,
            )
            .snapshots()
            .map((list) {
            return list.docs.map((e) {
              return MenuCategoryModel.fromFirestore(e);
            }).toList();
          });
  }

  Future<Object> createCategory(
      String categoryName, String restaurantId) async {
    try {
      await _db.collection("/menu").doc().set({
        "categoryName": categoryName,
        "menuItems": [],
        "restaurant_id": restaurantId,
      });
      return Success(200, "Category created Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }
  // Future<Object> createMenu(String name, String email, String password,
  //     String restaurantName, String restaurantId) async {
  //   try {
  //     UserCredential cred = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     await _db.collection("/Menus").doc().set({
  //       "uid": cred.user?.uid ?? "",
  //       "name": name,
  //       "email": email,
  //       "assigned_restaurant": restaurantName,
  //       "restaurant_id": restaurantId,
  //       "role": "restaurant_Menu",
  //     });
  //     return Success(200, "Menu created successfully !!");
  //   } on FirebaseAuthException catch (e) {
  //     return Failure(101, e.code);
  //   }
  // }
}
