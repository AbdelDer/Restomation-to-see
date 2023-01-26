import 'package:flutter/widgets.dart';
import 'package:restomation/MVVM/Models/model_error.dart';

class CustomerOrderViewModel extends ChangeNotifier {
  bool _loading = false;
  ModelError? _modelError;

  bool get loading => _loading;
  ModelError? get modelError => _modelError;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setModelError(ModelError? modelError) {
    _modelError = modelError;
  }
}
