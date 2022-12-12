import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/Login%20Model/login_model.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Authentication/authentication_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class LoginViewModel extends ChangeNotifier {
  bool _loading = false;
  LoginModel? _loggedInUser;
  ModelError? _modelError;

  bool get loading => _loading;
  LoginModel? get loggedInUser => _loggedInUser;
  ModelError? get modelError => _modelError;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setLoggedInUser(LoginModel loggedInUser) {
    _loggedInUser = loggedInUser;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future loginUser(String email, String password) async {
    setLoading(true);
    var response = await AuthMethods().loginUser(email, password);
    if (response is Success) {
      setLoggedInUser(response.response as LoginModel);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
