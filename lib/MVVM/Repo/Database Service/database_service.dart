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

  static getAllresturants() {
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

  static Future createCategory(String resturantKey, String categoryName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .push()
        .set({"categoryName": categoryName});
  }

  static Future createCategoryItems(
      String resturantKey, String categoryKey, String categoryName) async {
    await db
        .ref()
        .child("resturants")
        .child(resturantKey)
        .child("menu")
        .child(categoryKey)
        .child(categoryName)
        .push()
        .set(
      {
        "name": "Sambar Rice",
        "price": "₹100",
        "rating": "4.2",
        "description": "A typical South Indian mildy spicy sambar rice ...",
        "image":
            "https://www.archanaskitchen.com/images/archanaskitchen/0-Archanas-Kitchen-Recipes/Mixed_Vegetable_Sambar_Rice-5.jpg",
        "reviews": "(142)",
      },
    );
  }
}
