import 'package:cloud_firestore/cloud_firestore.dart';

class TablesModel {
  TablesModel({
    required this.id,
    required this.name,
    required this.qrLink,
    required this.restaurantId,
  });
  String? id;
  final String? name;
  final String? restaurantId;
  final String? qrLink;

  factory TablesModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> table) {
    Map doc = table.data();
    return TablesModel(
        id: table.id,
        name: doc["name"] ?? "No name provided",
        qrLink: doc["qrLink"] ?? "No path provided",
        restaurantId: doc["restaurant_id"] ?? "No restaurant ID provided");
  }
  factory TablesModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> table) {
    Map? doc = table.data();
    return TablesModel(
        id: table.id,
        name: doc?["name"] ?? "No name provided",
        qrLink: doc?["qrLink"] ?? "No path provided",
        restaurantId: doc?["restaurant_id"] ?? "No restaurant ID provided");
  }
}
