import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class RestaurantsViewModel extends ChangeNotifier {
  bool _loading = false;
  ListResult? _listResult;
  ModelError? _modelError;
  String? _restaurants;

  bool get loading => _loading;
  ListResult? get listResult => _listResult;
  ModelError? get modelError => _modelError;
  String? get restaurants => _restaurants;

  RestaurantsViewModel() {
    getAllrestaurantss();
  }

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setAllrestaurantss(ListResult listResult) {
    _listResult = listResult;
  }

  setrestaurantssResponse(String restaurants) {
    _restaurants = restaurants;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  getAllrestaurantss() async {
    setLoading(true);
    var response = await StorageService.getAllResturants();
    if (response is Success) {
      setAllrestaurantss(response.response as ListResult);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }


  Future createrestaurants(
      String name, String fileName, Uint8List bytes) async {
    setLoading(true);
    var response =
        await DatabaseService.createrestaurants(name, fileName, bytes);
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
