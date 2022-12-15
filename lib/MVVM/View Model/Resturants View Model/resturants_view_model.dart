import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Restaurant%20Service/restaurant_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class RestaurantsViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _restaurants;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get restaurants => _restaurants;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setrestaurantssResponse(String restaurants) {
    _restaurants = restaurants;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createrestaurants(
      String name, String fileName, Uint8List bytes) async {
    setLoading(true);
    var response =
        await RestaurantService().createrestaurants(name, fileName, bytes);
    if (response is Success) {
      setrestaurantssResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
