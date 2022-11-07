import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Login%20Service/login_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class LoginViewModel extends ChangeNotifier {
  bool _loading = false;
  User? _loggedInUser;
  ModelError? _modelError;

  bool get loading => _loading;
  User? get loggedInUser => _loggedInUser;
  ModelError? get modelError => _modelError;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setLoggedInUser(User loggedInUser) {
    _loggedInUser = loggedInUser;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  loginUser(TextEditingController email, TextEditingController password) async {
    setLoading(true);
    var response = await LoginService.loginUser(email, password);
    if (response is Success) {
      setLoggedInUser(response.response as User);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
