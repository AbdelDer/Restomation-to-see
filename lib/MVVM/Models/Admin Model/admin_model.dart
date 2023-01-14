import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.uid,
    required this.assignedRestaurant,
  });
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? uid;
  final String? assignedRestaurant;

  factory AdminModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> e) {
    Map doc = e.data();
    return AdminModel(
      id: e.id,
      name: doc["name"] ?? "No name provided",
      email: doc["email"] ?? "No email provided",
      role: doc["role"] ?? "No role provided",
      uid: doc["uid"] ?? "No uid provided",
      assignedRestaurant: doc["assigned_restaurant"] ?? "No restaurant provided",
    );
  }
}
