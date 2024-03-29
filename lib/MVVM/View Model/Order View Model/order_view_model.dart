import 'package:flutter/foundation.dart';

import '../../Models/model_error.dart';
import '../../Repo/Order Service/order_service.dart';
import '../../Repo/api_status.dart';

class OrderViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;
  String? _orders;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;
  String? get orders => _orders;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setOrderResponse(String order) {
    _orders = order;
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }

  Future getOrders(String restaurantId) async {
    setLoading(true);
    var response = await OrderService().getOrders(restaurantId);

    if (response is Success) {
      setOrderResponse(response as String);
    }
    if (response is Failure) {
      ModelError modelError = ModelError(response.code, response.errorResponse);
      setModelError(modelError);
    }
    setLoading(false);
  }
}
