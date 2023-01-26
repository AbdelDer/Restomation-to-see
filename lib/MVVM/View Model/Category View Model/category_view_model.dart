import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

import '../../Repo/Menu Service/menu_service.dart';

class MenuCategoryViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _menuCategory;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get menuCategory => _menuCategory;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setMenuCategorysResponse(String menuCategory) {
    _menuCategory = menuCategory;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createMenuCategory(String name, String restaurantId) async {
    setLoading(true);
    setModelError(null);
    var response = await MenuService().createCategory(name, restaurantId);
    if (response is Success) {
      setMenuCategorysResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }

  Future createMenuCategoryItem(String categoryId, String restaurantId,
      MenuItemModel menuItemModel, Uint8List imageBytes) async {
    setLoading(true);
    setModelError(null);
    var response = await MenuService().createMenuCategoryItem(
        categoryId, restaurantId, menuItemModel, imageBytes);
    if (response is Success) {
      setMenuCategorysResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
