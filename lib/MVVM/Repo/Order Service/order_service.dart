import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restomation/MVVM/Models/Order%20Model/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future getOrders(String restaurantId) {

   return  FirebaseFirestore.instance.collection("/restaurants").doc(restaurantId).collection("orders")
        .snapshots().forEach((element) {
        for (var elements in element.docs) {
          FirebaseFirestore.instance.collection("/restaurants").doc(restaurantId.toString()).collection("orders").doc(elements.id.toString()).collection("order_items").snapshots()
          .map((list) {
            return list.docs.map((e) {
              return OrderModel.fromFirestore(e);
            }).toList();
          });


      }
    });


  }
}
