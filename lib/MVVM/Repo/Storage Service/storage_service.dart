import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class StorageService {
  static FirebaseStorage storage = FirebaseStorage.instance;
  Future<void> uploadFile(Uint8List fileBytes, String fileExtension) async {
    try {
      await storage.ref("vegies/logo.$fileExtension").putData(fileBytes);
      Fluttertoast.showToast(msg: "Uploaded");
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.code);
    }
  }

  static Future<Object> getAllResturants() async {
    try {
      ListResult resturantsList = await storage.ref().listAll();
      return Success(200, resturantsList);
    } on FirebaseException catch (e) {
      return Failure(101, e.code);
    }
  }

  static Future<Object> createResturant(
      String name, String fileExtension, Uint8List bytes) async {
    try {
      await storage.ref("$name/logo/logo.$fileExtension").putData(bytes);
      return Success(200, "Resturant created successfully !!");
    } on FirebaseException catch (e) {
      return Failure(101, e.code);
    }
  }
}
