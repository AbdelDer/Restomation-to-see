import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Repo/Tables Service/tables_service.dart';

class TablesViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _tables;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get tables => _tables;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setTablessResponse(String tables) {
    _tables = tables;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createTables(String name, String qrLink, String restaurantId) async {
    setLoading(true);
    var response =
        await TablesService().createTables(name, qrLink, restaurantId);
    if (response is Success) {
      setTablessResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
