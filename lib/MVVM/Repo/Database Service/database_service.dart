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
      String name, String fileExtension, Uint8List bytes) async {
    try {
      await storage
          .ref("restaurants/$name/logo/logo.$fileExtension")
          .putData(bytes);
      db.ref().child("restaurants").child(name).set(
        {
          "restaurantsName": name,
          "imagePath": "restaurants/$name/logo/logo.$fileExtension"
        },
      );
      return Success(200, "restaurants created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }

  static Future<Map?> loginUser(String email, String password) async {
    Map? authUser;
    Stream<DatabaseEvent> superAdmin = db.ref().child("admins").onValue;
    StreamSubscription<DatabaseEvent> adminListener =
        superAdmin.listen((event) {
      Map users = event.snapshot.value as Map;
      List userKeys = users.keys.toList();
      for (var e in userKeys) {
        if (users[e]["email"] == email && users[e]["password"] == password) {
          authUser = users[e];
        }
      }
    });
    await Future.delayed(const Duration(seconds: 2), () {
      adminListener.cancel();
    });
    return authUser;
  }

  static getAllrestaurants() {
    Query dbref = db.ref().child("restaurants");
    return dbref;
  }

  static getrestaurantsCategories(
    String restaurantsKey,
  ) {
    Query dbref =
        db.ref().child("restaurants").child(restaurantsKey).child("menu");
    return dbref;
  }

  static getStaffCategories(
    String restaurantsKey,
  ) {
    Query dbref =
        db.ref().child("restaurants").child(restaurantsKey).child("staff");
    return dbref;
  }

  static getrestaurantsTables(
    String restaurantsKey,
  ) {
    Query dbref =
        db.ref().child("restaurants").child(restaurantsKey).child("tables");
    return dbref;
  }

  static getsinglerestaurantsCategories(
    String restaurantsKey,
    String categoryKey,
    String categoryName,
  ) {
    Query dbref = db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName);
    return dbref;
  }

  static getsinglerestaurantsStaffCategories(
    String restaurantsKey,
    String staffCategoryKey,
    String staffCategoryName,
  ) {
    Query dbref = db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("staff")
        .child(staffCategoryKey)
        .child(staffCategoryName);
    return dbref;
  }

  static createSubAdminRestaurant(
    String restaurantsKey,
    String name,
    String email,
    String password,
    String path,
  ) async {
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("admins")
        .child(name)
        .set({"email": email, "password": password, "path": path});
  }

  static Future createCategory(
      String restaurantsKey, String categoryName) async {
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("menu")
        .child(categoryName)
        .set({"categoryName": categoryName});
  }

  static Future createStaffCategory(
      String restaurantsKey, String staffCategoryName) async {
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("staff")
        .push()
        .set({"staffCategoryName": staffCategoryName});
  }

  static Future createTable(
      String restaurantsKey, String tableName, String qrLink) async {
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("tables")
        .child(tableName)
        .set({"qrLink": qrLink});
  }

  static Future updateTable(
      String restaurantsKey, String tableKey, String tableName) async {
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("tables")
        .child(tableKey)
        .set({"tableName": tableName});
  }

  static Future createCategoryItems(
      String restaurantsKey,
      String categoryKey,
      String restaurantsName,
      String categoryName,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage
        .ref("restaurants/$restaurantsName/menu/$categoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("menu")
        .child(categoryKey)
        .child("items")
        .child(item["name"])
        .set(item);
  }

  static Future createStaffCategoryPerson(
      String restaurantsKey, String fileName, Map item, Uint8List bytes) async {
    await storage
        .ref("restaurants/$restaurantsKey/staff/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("staff")
        .child(item["name"])
        .set(item);
  }

  static Future updateCategoryItems(
      String restaurantsKey,
      String categoryKey,
      String itemKey,
      String restaurantsName,
      String categoryName,
      String oldImagePath,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage.ref().child(oldImagePath).delete();
    await storage
        .ref()
        .child("restaurants/$restaurantsName/menu/$categoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName)
        .child(itemKey)
        .set(item);
  }

  static Future updateStaffCategoryPerson(String restaurantsKey, String itemKey,
      String oldImagePath, String fileName, Map item, Uint8List bytes) async {
    await storage.ref().child(oldImagePath).delete();
    await storage
        .ref()
        .child("restaurants/$restaurantsKey/staff/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("staff")
        .child(itemKey)
        .set(item);
  }

  Future createOrder(
      String restaurantsKey, String tableKey, Map data, List cartItems) async {
    DatabaseReference reference = db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("orders")
        .child(tableKey);
    reference.set(data);
    DatabaseReference itemsRef = db
        .ref()
        .child("restaurants")
        .child(restaurantsKey)
        .child("orders")
        .child(reference.key!)
        .child("items");
    for (var element in cartItems) {
      await itemsRef.child(element["name"]).set(element);
    }
  }
}
