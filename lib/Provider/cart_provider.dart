import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';

class Cart extends ChangeNotifier {
  List<CartItemModel> cartItems = [];
  addCartItem(CartItemModel value) {
    int index = cartItems.indexWhere((element) => element.name == value.name);
    if (index != -1 && value.quantity > 1) {
      int index = cartItems.indexWhere((element) => element.name == value.name);
      cartItems[index] = value;
    } else {
      cartItems.add(value);
    }
    notifyListeners();
  }

  void updateState() {
    notifyListeners();
  }

  String getTotalPrice(List<CartItemModel> items) {
    double total = 0;
    for (var element in items) {
      total += double.parse(element.price) * element.quantity;
    }
    return total.toString();
  }

  updateCartItem(CartItemModel value, String instructions) {
    int index = cartItems.indexWhere((element) => element.name == value.name);
    cartItems[index].instructions = instructions;
    Fluttertoast.showToast(msg: "Instructions added successfully !");
  }

  deleteCartItem(CartItemModel value) {
    int index = cartItems.indexWhere((element) {
      return element.name == value.name;
    });
    cartItems.removeAt(index);

    notifyListeners();
  }

  clearCart() {
    cartItems.clear();
    notifyListeners();
  }
}
