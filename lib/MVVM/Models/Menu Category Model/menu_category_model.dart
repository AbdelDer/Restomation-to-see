import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';

class MenuCategoryModel {
  MenuCategoryModel(
      {required this.id,
      required this.categoryName,
      required this.restaurantId,
      required this.menuItemModel});
  final String? id;
  final String? categoryName;
  final String? restaurantId;
  final List<MenuItemModel>? menuItemModel;

  factory MenuCategoryModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> e) {
    Map doc = e.data();
    return MenuCategoryModel(
      id: e.id,
      categoryName: doc["categoryName"] ?? "No category name provided",
      restaurantId: doc["restaurant_id"] ?? "No restaurant id provided",
      menuItemModel: (doc["menuItems"] as List)
          .map((e) => MenuItemModel.fromFirestore(e))
          .toList(),
    );
  }
}
