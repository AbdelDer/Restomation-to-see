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
        return TablesModel.fromFirestore(e.data());
      }).toList();
    });
  }

  Future<Object> createTables(String name, String qrLink, String restaurantId) async {
    try {
      var names;
      final test= await FirebaseFirestore.instance.collection(
          "/restaurants")
          .doc(restaurantId ?? "")
          .collection("tables").where("name",isEqualTo:name ).get();

      for(var v in test.docs){
       names = v.reference.delete();
       print(names.toString());
      }

      _db.collection("/restaurants")
          .doc(restaurantId)
          .collection("tables")
          .doc()
          .set({"name": name, "qrLink": qrLink, "restaurant_id": restaurantId});
      return Success(200, "Tables created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }
}
