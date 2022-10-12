import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';

class ResturantViewModel extends ChangeNotifier {
  bool _loading = false;
  ListResult? _listResult;
  ModelError? _modelError;
  String? _resturant;

  bool get loading => _loading;
  ListResult? get listResult => _listResult;
  ModelError? get modelError => _modelError;
  String? get resturant => _resturant;

  ResturantViewModel() {
    getAllResturants();
  }

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setAllResturants(ListResult listResult) {
    _listResult = listResult;
  }

  setResturantsResponse(String resturant) {
    _resturant = resturant;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  getAllResturants() async {
    setLoading(true);
    var response = await StorageService.getAllResturants();
    if (response is Success) {
      setAllResturants(response.response as ListResult);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }

  Future createResturant(
      String name, String fileExtension, Uint8List bytes) async {
    setLoading(true);
    var response =
        await DatabaseService.createResturant(name, fileExtension, bytes);
    if (response is Success) {
      setResturantsResponse(response.response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
