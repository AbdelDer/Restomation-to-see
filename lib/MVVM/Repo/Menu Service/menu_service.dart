import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class MenuService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
//
//
//      GET WHOLE MENU
  Stream<List<MenuCategoryModel>> getMenu(String restaurantId) {
    return restaurantId.isEmpty
        ? _db.collection("/menu").snapshots().map((list) {
            return list.docs.map((e) {
              return MenuCategoryModel.fromFirestore(e);
            }).toList();
          })
        : _db
            .collection("/restaurants")
            .doc(restaurantId)
            .collection("menu")
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

//
//
//        CREATE MENU ITEMS
  Future<Object> createMenuCategoryItem(String categoryId, String restaurantId,
      MenuModel menuModel, Uint8List imageBytes) async {
    try {
      await storage.ref(menuModel.imagePath).putData(imageBytes);
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("menu")
          .doc(categoryId)
          .update(
        {
          "menuItems": FieldValue.arrayUnion(
            [menuModel.toJson(menuModel)],
          ),
        },
      );
      return Success(200, "Menu Item added Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }

//
//
//      DELETE MENU ITEMS
  Future<Object> deleteMenuCategoryItem(String categoryId, String restaurantId,
      MenuModel menuModel, Uint8List imageBytes) async {
    try {
      await storage.ref(menuModel.imagePath).putData(imageBytes);
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("menu")
          .doc(categoryId)
          .update(
        {
          "menuItems": FieldValue.arrayRemove(
            [menuModel.toJson(menuModel)],
          ),
        },
      );
      return Success(200, "Menu Item added Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }

//
//
//        CREATE CATEGORY
  Future<Object> createCategory(
      String categoryName, String restaurantId) async {
    try {
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("menu")
          .doc()
          .set({
        "categoryName": categoryName,
        "menuItems": [],
        "restaurant_id": restaurantId,
      });
      return Success(200, "Category created Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }
}
