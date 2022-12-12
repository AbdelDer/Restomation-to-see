import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class DatabaseService extends StorageService {
  static FirebaseDatabase db = FirebaseDatabase.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static Future<Object> createrestaurants(
      String name, String fileName, Uint8List bytes) async {
    try {
      await storage.ref("restaurantLogos/$fileName").putData(bytes);
      db.ref().child("restaurants").push().set(
        {
          "imageName": fileName,
          "restaurantsName": name,
          "imagePath": "restaurantLogos/$fileName",
        },
      );
      return Success(200, "restaurants created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }

  static Future<Map?> loginUser(String email, String password) async {
    Map? authUser;
    DatabaseEvent superAdmin = await db
        .ref()
        .child("super_admins")
        .orderByChild("email")
        .equalTo(email)
        .once();
    Map? superUsers = superAdmin.snapshot.value as Map?;
    if (superUsers != null) {
      List superUserKeys = superUsers.keys.toList();
      for (var e in superUserKeys) {
        if (superUsers[e]["email"] == email &&
            superUsers[e]["password"] == password) {
          authUser = superUsers[e];
        }
      }
    }
    DatabaseEvent restaurantAdmin = await db
        .ref()
        .child("admins")
        .orderByChild("email")
        .equalTo(email)
        .once();

    Map? users = restaurantAdmin.snapshot.value as Map?;
    if (users != null) {
      List userKeys = users.keys.toList();
      for (var e in userKeys) {
        if (users[e]["email"] == email && users[e]["password"] == password) {
          authUser = users[e];
        }
      }
    }

    return authUser;
  }

  static Future createSubAdminRestaurant(String restaurantsKey, String name,
      String email, String password, String imageName,
      {bool update = false, String? personKey}) async {
    if (update && personKey != null) {
      await db.ref().child("admins").child(personKey).update({
        "name": name,
        "email": email,
        "password": password,
        "role": "sub_admin",
        "assigned_restaurant": restaurantsKey
      });
    } else {
      await db.ref().child("admins").push().set({
        "name": name,
        "email": email,
        "password": password,
        "role": "sub_admin",
        "imageName": imageName,
        "assigned_restaurant": restaurantsKey
      });
    }
  }

  static Future createCategory(
      String restaurantsKey, String categoryName) async {
    await db
        .ref()
        .child("menu_categories")
        .child(restaurantsKey)
        .push()
        .set({"categoryName": categoryName});
  }

  static Future createTable(
      String restaurantsKey, String tableName, String qrLink) async {
    await db.ref().child("tables").child(restaurantsKey).push().set({
      "table_name": tableName,
      "qrLink": qrLink,
    });
  }

  static Future updateTable(String restaurantsKey, String tableKey,
      String tableName, String qrLink) async {
    await db
        .ref()
        .child("tables")
        .child(restaurantsKey)
        .child(tableKey)
        .update({
      "table_name": tableName,
      "qrLink": qrLink,
    });
  }

  static Future createCategoryItems(String restaurantsName, String categoryKey,
      {String? fileName,
      required Map<String, Object?> item,
      Uint8List? bytes,
      required bool isExsiting}) async {
    if (!isExsiting) {
      await storage.ref("food_images/$fileName").putData(bytes!);
    }
    await db.ref().child("menu_items").child(restaurantsName).push().set(item);
  }

  static Future createStaffCategoryPerson(String restaurantsName,
      String fileName, Map item, Uint8List bytes) async {
    await storage.ref("staff/$restaurantsName/$fileName").putData(bytes);
    await db.ref().child("staff").push().set(item);
  }

  static Future updateCategoryItems(String restaurantsName, String categoryKey,
      String itemKey, String oldImagePath,
      {String? fileName,
      required Map<String, Object?> item,
      Uint8List? bytes,
      required bool isExsiting}) async {
    if (!isExsiting) {
      if (!(bytes == null)) {
        await storage.ref("food_images/$fileName").putData(bytes);
      }
    }

    await db
        .ref()
        .child("menu_items")
        .child(restaurantsName)
        .child(itemKey)
        .update(item);
  }

  static Future updateStaffCategoryPerson(
      String restaurantsKey,
      String itemKey,
      String oldImagePath,
      String fileName,
      Map<String, Object?> item,
      Uint8List bytes) async {
    await storage.ref().child(oldImagePath).delete();
    await storage.ref().child("staff/$restaurantsKey/$fileName").putData(bytes);
    await db.ref().child("staff").child(itemKey).update(item);
  }

  Future createOrder(String restaurantsKey, String tableKey, Map data,
      List cartItems, String name) async {
    await db.ref().child("orders").child(restaurantsKey).push().set(data);
    db
        .ref()
        .child("order_items")
        .child(restaurantsKey)
        .child(name)
        .push()
        .set(cartItems);
  }

  Future updateOrderItems(String restaurantsKey, List cartItems, String name,
      String orderItemsKey, int itemCount) async {
    for (var i = 0; i < cartItems.length; i++) {
      await db
          .ref()
          .child("order_items")
          .child(restaurantsKey)
          .child(name)
          .child(orderItemsKey)
          .update({(i + (itemCount)).toString(): cartItems[i]});
    }
    itemCount++;
  }
}
