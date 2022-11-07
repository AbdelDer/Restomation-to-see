import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class LoginService {
  static Future<Object> loginUser(
      TextEditingController email, TextEditingController password) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email.text, password: password.text);

      return Success(200, userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Failure(103, e.code);
    }
  }
}
