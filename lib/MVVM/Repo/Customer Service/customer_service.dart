import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/Customer Model/customer_order_model.dart';
import '../api_status.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<CustomerOrderModel>> getCustomerOrder(
      String restaurantId, String tableId) {
    return _db
        .collection("/restaurants")
        .doc(restaurantId)
        .collection("orders")
        .where("tableId", isEqualTo: tableId)
        .snapshots()
        .map((list) {
      return list.docs.map((e) {
        return CustomerOrderModel.fromFirestore(e);
      }).toList();
    });
  }

  Future<Object> callWaiter(String restaurantId, String waiterName) async {
    try {
      await _db
          .collection("/restaurants")
          .doc(restaurantId)
          .collection("staff")
          .where("name", isEqualTo: waiterName)
          .get()
          .then((value) {
        value.docs.map((e) => e.data());
      });
      return Success(200, "Called waiter Succesfully");
    } on FirebaseException catch (e) {
      return Failure(404, e.code);
    }
  }
}
