import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Repo/Staff Service/staff_service.dart';

class StaffViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _staff;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get staff => _staff;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setStaffsResponse(String staff) {
    _staff = staff;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createStaff(
    String name,
    String email,
    String phoneNo,
    String restaurantId,
    String restaurantName,
    String role,
    String password,
  ) async {
    setLoading(true);
    var response = await StaffService().createStaff(name, email, phoneNo, restaurantId, restaurantName, role, password,);
    if (response is Success) {
      setStaffsResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }


}
