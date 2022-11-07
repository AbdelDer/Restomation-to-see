import 'package:flutter/cupertino.dart';

class Cart extends ChangeNotifier {
  List<Map> cartItems = [];
  addCartItem(Map value) {
    if (cartItems.contains(value) && value["quantity"] > 1) {
      int index =
          cartItems.indexWhere((element) => element["name"] == value["name"]);
      cartItems[index] = value;
    } else {
      cartItems.add(value);
    }

    notifyListeners();
  }

  deleteCartItem(value) {
    if (cartItems.contains(value) && value["quantity"] > 0) {
      int index =
          cartItems.indexWhere((element) => element["name"] == value["name"]);
      cartItems[index] = value;
    } else {
      cartItems.remove(value);
    }

    notifyListeners();
  }
}
