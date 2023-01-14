import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restomation/MVVM/Models/Login%20Model/login_model.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<Object> loginUser(String email, String password) async {

    try {
      Map<String, dynamic> data = {};
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await firestore
          .collection("/users")
          .where("uid", isEqualTo: cred.user!.uid)
          .get()
          .then((value) {
        data = value.docs[0].data();
      });
      return Success(200, loginModelFromJson(jsonEncode(data)));
    } on FirebaseAuthException catch (e) {
      return Failure(404, e.code);
    }
  }
}
