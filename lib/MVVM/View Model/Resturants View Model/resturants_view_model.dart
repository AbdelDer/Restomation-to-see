import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Restaurant%20Service/restaurant_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class RestaurantsViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  RestaurantModel? _restaurantModel;
  String? _restaurants;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get restaurants => _restaurants;
  RestaurantModel? get restaurantModel => _restaurantModel;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setRestaurantModel(RestaurantModel restaurantModel) {
    _restaurantModel = restaurantModel;
  }

  setrestaurantsResponse(String restaurants) {
    _restaurants = restaurants;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future createrestaurants(
      String name, String fileName, Uint8List bytes) async {
    setLoading(true);
    setModelError(null);
    var response =
        await RestaurantService().createrestaurants(name, fileName, bytes);
    if (response is Success) {
      setrestaurantsResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }

  Future getSingleRestaurant(
    String restaurantId,
  ) async {
    setLoading(true);
    setModelError(null);
    var response = await RestaurantService().getSingleRestaurant(restaurantId);
    if (response is Success) {
      setRestaurantModel(response.response as RestaurantModel);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
