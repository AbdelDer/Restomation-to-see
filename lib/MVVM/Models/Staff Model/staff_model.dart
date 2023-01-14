import 'package:cloud_firestore/cloud_firestore.dart';

class
StaffModel {
  StaffModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.phoneNo,
    required this.role,
    required this.email,
    required this.restaurantId,
    required this.restaurantName,
  });
  String? id;
  final String? uid;
  final String? name;
  final String? email;
  final String? phoneNo;
  final String? restaurantId;
  final String? restaurantName;
  final String? role;

  factory StaffModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> staff) {
    Map doc = staff.data();
    return StaffModel(
        id: staff.id,
        uid: doc["uid"] ?? "No id provided",
        name: doc["name"] ?? "No name provided",
        email: doc["email"] ?? "No email provided",
        phoneNo: doc["phone_no"],
        role: doc["role"] ?? "No role provided",
        restaurantId: doc["restaurant_id"] ?? "No restaurant ID provided",
        restaurantName: doc["assigned_restaurant"] ?? "No restaurant Name provided");
  }
}
