import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  RestaurantModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });
  final String? id;
  final String? name;
  final String? imagePath;

  factory RestaurantModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> e) {
    Map doc = e.data();
    return RestaurantModel(
      id: e.id,
      name: doc["name"] ?? "No name provided",
      imagePath: doc["imagePath"] ?? "No path provided",
    );
  }
  static String toJson(RestaurantModel restaurantModel) {
    return jsonEncode({
      "id": restaurantModel.id,
      "name": restaurantModel.name,
      "imagePath": restaurantModel.imagePath
    });
  }

  factory RestaurantModel.fromJson(Map e) {
    return RestaurantModel(
      id: e["id"],
      name: e["name"] ?? "No name provided",
      imagePath: e["imagePath"] ?? "No path provided",
    );
  }
}
