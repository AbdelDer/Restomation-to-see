import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  updateCartItem(Map value, String instructions) {
    int index =
        cartItems.indexWhere((element) => element["name"] == value["name"]);
    cartItems[index]["instructions"] = instructions;
    Fluttertoast.showToast(msg: "Instructions added successfully !");
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
