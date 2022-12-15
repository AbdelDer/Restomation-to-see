import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final FirebaseStorage _storage = FirebaseStorage.instance;
  Stream<List<RestaurantModel>> getRestaurants() {
    return _db.collection("/restaurants").snapshots().map((list) {
      return list.docs.map((e) {
        return RestaurantModel.fromFirestore(e);
      }).toList();
    });
  }

  Future<Object> createrestaurants(
      String name, String fileName, Uint8List bytes) async {
    try {
      await _storage.ref("restaurantLogos/$fileName").putData(bytes);
      _db.collection("restaurants").doc().set({
        "name": name,
        "imagePath": "restaurantLogos/$fileName",
      });
      return Success(200, "restaurants created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }
}
