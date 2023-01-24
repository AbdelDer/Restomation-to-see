import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/Tables%20Model/tables_model.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Repo/Tables Service/tables_service.dart';

class TablesViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _tables;
  TablesModel? _tablesModel;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get tables => _tables;
  TablesModel? get tablesModel => _tablesModel;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setTablesResponse(String tables) {
    _tables = tables;
  }

  setTablesModel(TablesModel tablesModel) {
    _tablesModel = tablesModel;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createTables(String name,  String restaurantId) async {
    setLoading(true);
    setModelError(null);
    var response =
        await TablesService().createTables(name,  restaurantId);
    if (response is Success) {
      setTablesResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }

  Future updateTables(String name, String restaurantId, String tableId) async {
    setLoading(true);
    setModelError(null);
    var response =
        await TablesService().updateTables(name, restaurantId, tableId);
    if (response is Success) {
      setTablesResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }

  Future getSingleTable(String restaurantId, String tableId) async {
    setLoading(true);
    setModelError(null);
    var response = await TablesService().getSingleTable(restaurantId, tableId);
    if (response is Success) {
      setTablesModel(response.response as TablesModel);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
