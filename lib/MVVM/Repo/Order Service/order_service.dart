import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restomation/MVVM/Models/Order%20Model/order_model.dart';

import '../api_status.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future getOrders(String restaurantId) {
    return _db
        .collection("/restaurants")
        .doc(restaurantId)
        .collection("orders")
        .snapshots()
        .forEach((element) {
      for (var elements in element.docs) {
        _db
            .collection("/restaurants")
            .doc(restaurantId.toString())
            .collection("orders")
            .doc(elements.id.toString())
            .collection("order_items")
            .snapshots()
            .map((list) {
          return list.docs.map((e) {
            return OrderModel.fromFirestore(e);
          }).toList();
        });
      }
    });
  }

  Future createOrder(String restaurantId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("orders")
          .doc()
          .set(data);
      return Success(200, "Order created Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }

  Future updateOrder(
      String restaurantId, String tableId, List cartItems) async {
    try {
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("orders")
          .doc(tableId)
          .update(
        {
          "menuItems": FieldValue.arrayUnion(cartItems),
        },
      );
      return Success(200, "Menu Item added Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }

  Future checkExisitingOrder(String restaurantId, String tableId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> doc = await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("orders")
          .where("tableId", isEqualTo: tableId)
          .get();
      return Success(200, doc);
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }
}
