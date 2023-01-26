import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Repo/Admin Service/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _admin;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get admin => _admin;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setAdminsResponse(String admin) {
    _admin = admin;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createAdmin(String name, String email, String password,
      String restaurantName, String restaurantId) async {
    setLoading(true);
    var response = await AdminService().createAdmin(
      name,
      email,
      password,
      restaurantName,
      restaurantId,
    );
    if (response is Success) {
      setAdminsResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
