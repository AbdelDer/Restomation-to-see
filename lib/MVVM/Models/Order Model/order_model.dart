import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  OrderModel({
    this.id,
    this.category,
    this.description,
    this.image,
    this.key,
    this.name,
    this.price,
    this.rating,
    this.reviews,
    this.status,
    this.type,
    this.upselling,
    this.order,
    this.quantity});

  String? id;
  final String? category;
  final String? description;
  final String? image;
  final String? key;
  final String? name;
  final String? price;
  var quantity;
  final String? rating;
  final String? reviews;
  final String? status;
  final String? type;
  final String? upselling;
  final String? order;

  factory OrderModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> order) {
    Map doc = order.data();
    return OrderModel(
        id:order.id,
        category: doc["category"]??"No category provided",
        description: doc["description"]?? "No description provided",
         image: doc["image"]?? "No image provided",
        key: doc["key"]?? "No key provided",
        name: doc["name"]?? "No name provided",
        price: doc["price"]?? "No price provided",
         quantity: doc["quantity"]??"No Quantity provided",
        rating: doc["rating"]?? "No rating provided",
        reviews: doc["reviews"]?? "No reviews provided",
        status: doc["status"]?? "No reviews provided",
        type: doc["type"]?? "No type provided",
        upselling: doc["upselling"]?? "No upselling provided",
        order: doc["upselling"]?? "No upselling provided"
    );
  }

}
