import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';

class CustomerOrderModel {
  CustomerOrderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isTableClean,
    required this.hasNewItems,
    required this.orderStatus,
    required this.tableId,
    required this.tableName,
    required this.waiter,
    required this.orderItems,
  });
  final String? id;
  final String? name;
  final String? phone;
  final String? isTableClean;
  final String? hasNewItems;
  final String? orderStatus;
  final String? tableId;
  final String? tableName;
  final String? waiter;
  final List<CartItemModel>? orderItems;

  factory CustomerOrderModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> e) {
    Map doc = e.data();
    return CustomerOrderModel(
        id: e.id,
        name: doc["name"],
        phone: doc["phone"],
        isTableClean: doc["isTableClean"],
        hasNewItems: doc["hasNewItems"],
        orderStatus: doc["orderStatus"],
        tableId: doc["tableId"],
        tableName: doc["tableName"],
        waiter: doc["waiter"],
        orderItems: (doc["orderItems"] as List<dynamic>)
            .map((e) => CartItemModel.fromFirestore(e))
            .toList());
  }
}
