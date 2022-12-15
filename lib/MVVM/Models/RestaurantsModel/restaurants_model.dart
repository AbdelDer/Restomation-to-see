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
}
