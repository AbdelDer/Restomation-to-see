import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restomation/MVVM/Models/Tables%20Model/tables_model.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class TablesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<TablesModel>> getTables(String restaurantId) {
    return _db
        .collection("/restaurants")
        .doc(restaurantId)
        .collection("tables")
        // .where("restaurant_id", isEqualTo: restaurantId)
        .snapshots()
        .map((list) {
      return list.docs.map((e) {
        return TablesModel.fromFirestore(e);
      }).toList();
    });
  }

  Future<Object> getSingleTable(String restaurantId, String tableId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> res = await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("tables")
          .doc(tableId)
          .get();
      return Success(200, TablesModel.fromDocumentSnapshot(res));
    } catch (e) {
      return Failure(101, e.toString());
    }
  }

  Future<Object> createTables(
      String name, String qrLink, String restaurantId) async {
    try {
      _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("tables")
          .doc()
          .set({"name": name, "qrLink": qrLink, "restaurant_id": restaurantId});
      return Success(200, "Tables created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }

  Future<Object> updateTables(
      String name, String restaurantId, String tableId) async {
    try {
      _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("tables")
          .doc(tableId)
          .update({
        "name": name,
      });
      return Success(200, "Tables update successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }
}
