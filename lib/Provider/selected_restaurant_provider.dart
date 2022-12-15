import 'package:flutter/foundation.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';

class SelectedRestaurantProvider extends ChangeNotifier {
  RestaurantModel? _restaurantModel;
  RestaurantModel? get restaurantModel => _restaurantModel;
  updateSelectedRestaurant(RestaurantModel restaurantModel) {
    _restaurantModel = restaurantModel;
    notifyListeners();
  }
}
