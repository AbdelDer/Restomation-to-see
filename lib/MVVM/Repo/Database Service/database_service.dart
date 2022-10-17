import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class DatabaseService extends StorageService {
  static FirebaseDatabase db = FirebaseDatabase.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static Future<Object> createResturant(
      String name, String fileExtension, Uint8List bytes) async {
    try {
      await storage
          .ref("resturants/$name/logo/logo.$fileExtension")
          .putData(bytes);
      db.ref().child("resturants").push().set(
        {
          "resturantName": name,
          "imagePath": "resturants/$name/logo/logo.$fileExtension"
        },
      );
      return Success(200, "Resturant created successfully !!");
    } catch (e) {
      return Failure(101, e.toString());
    }
  }

  static getAllResturants() {
    Query dbref = db.ref().child("resturants");
    return dbref;
  }


  static getResturantsCategories(
    String resturantKey,
  ) {
    Query dbref =
        db.ref().child("resturants").child(resturantKey).child("menu");
    return dbref;
  }

  static getStaffCategories(
    String resturantKey,
  ) {
    Query dbref =
        db.ref().child("resturants").child(resturantKey).child("staff");
    return dbref;
  }

  static getResturantsTables(
    String resturantKey,
  ) {
    Query dbref =
        db.ref().child("resturants").child(resturantKey).child("tables");
    return dbref;
  }

  static getsingleResturantsCategories(
    String resturantKey,
    String categoryKey,
    String categoryName,
  ) {
    Query dbref = db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName);
    return dbref;
  }

  static getsingleResturantsStaffCategories(
    String resturantKey,
    String staffCategoryKey,
    String staffCategoryName,
  ) {
    Query dbref = db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("staff")
        .child(staffCategoryKey)
        .child(staffCategoryName);
    return dbref;
  }

  static Future createCategory(String resturantKey, String categoryName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .push()
        .set({"categoryName": categoryName});
  }

  static Future createStaffCategory(
      String resturantKey, String staffCategoryName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("staff")
        .push()
        .set({"staffCategoryName": staffCategoryName});
  }

  static Future createTable(String resturantKey, String tableName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("tables")
        .push()
        .set({"tableName": tableName});
  }

  static Future updateTable(
      String resturantKey, String tableKey, String tableName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("tables")
        .child(tableKey)
        .set({"tableName": tableName});
  }

  static Future createCategoryItems(
      String resturantKey,
      String categoryKey,
      String resturantName,
      String categoryName,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage
        .ref("resturants/$resturantName/menu/$categoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName)
        .push()
        .set(item);
  }

  static Future createStaffCategoryPerson(
      String resturantKey,
      String resturantName,
      String staffCategoryKey,
      String staffCategoryName,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage
        .ref("resturants/$resturantName/staff/$staffCategoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("staff")
        .child(staffCategoryKey)
        .child(staffCategoryName)
        .push()
        .set(item);
  }

  static Future updateCategoryItems(
      String resturantKey,
      String categoryKey,
      String itemKey,
      String resturantName,
      String categoryName,
      String oldImagePath,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage.ref().child(oldImagePath).delete();
    await storage
        .ref()
        .child("resturants/$resturantName/menu/$categoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName)
        .child(itemKey)
        .set(item);
  }

  static Future updateStaffCategoryPerson(
      String resturantKey,
      String categoryKey,
      String itemKey,
      String resturantName,
      String categoryName,
      String oldImagePath,
      String fileName,
      Map item,
      Uint8List bytes) async {
    await storage.ref().child(oldImagePath).delete();
    await storage
        .ref()
        .child("resturants/$resturantName/staff/$categoryName/$fileName")
        .putData(bytes);
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("staff")
        .child(categoryKey)
        .child(categoryName)
        .child(itemKey)
        .set(item);
  }
}
