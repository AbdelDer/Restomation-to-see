import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      await storage.ref("vegies/$fileName").putData(fileBytes);
      Fluttertoast.showToast(msg: "Uploaded");
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.code);
    }
  }
}
