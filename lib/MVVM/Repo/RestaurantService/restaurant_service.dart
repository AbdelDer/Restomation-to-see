import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';

class RestaurantService extends ChangeNotifier {
  List<String>? restaurant;
  late StreamSubscription<DatabaseEvent> _resturantsListener;
  getRestaurants() {
    _resturantsListener =
        DatabaseService.db.ref().child("restaurants").onValue.listen((event) {
      List restaurantsKeys = (event.snapshot.value as Map).keys.toList();
      restaurant = restaurantsKeys as List<String>;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _resturantsListener.cancel();
  }
}
