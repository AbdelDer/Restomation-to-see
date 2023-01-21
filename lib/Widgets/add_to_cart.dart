import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/Provider/cart_provider.dart';

class AddToCart extends StatefulWidget {
  final MenuItemModel menuItemModel;
  const AddToCart({
    super.key,
    required this.menuItemModel,
  });

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int initialValue = 0;
  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();
    int index = cart.cartItems.indexWhere((element) =>
        element.name.toString().toLowerCase() ==
        widget.menuItemModel.name.toString().toLowerCase());
    if (index == -1) {
      initialValue = 0;
    }
    if (index != -1) {
      initialValue = cart.cartItems[index].quantity;
    }
    return InkWell(
      onTap: () {
        if (initialValue == 0) {
          setState(() {
            initialValue++;
          });

          context.read<Cart>().addCartItem(CartItemModel(
              name: widget.menuItemModel.name ?? "",
              description: widget.menuItemModel.description ?? "",
              imagePath: widget.menuItemModel.imagePath ?? "",
              price: widget.menuItemModel.price ?? "",
              reviews: widget.menuItemModel.reviews ?? "",
              status: widget.menuItemModel.status ?? "",
              type: widget.menuItemModel.type ?? "",
              upselling: widget.menuItemModel.upselling ?? "",
              quantity: initialValue,
              cookingStatus: "pending"));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        width: 100,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  offset: Offset(0, 0),
                  spreadRadius: 2,
                  blurRadius: 2,
                  color: Colors.black12)
            ],
            color: Colors.white),
        child: initialValue == 0
            ? const Text(
                "ADD",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          initialValue--;
                          cart.cartItems[index].quantity = initialValue;
                          cart.updateState();
                        });
                        if (initialValue == 0) {
                          cart.deleteCartItem(CartItemModel(
                              name: widget.menuItemModel.name ?? "",
                              description:
                                  widget.menuItemModel.description ?? "",
                              imagePath: widget.menuItemModel.imagePath ?? "",
                              price: widget.menuItemModel.price ?? "",
                              reviews: widget.menuItemModel.reviews ?? "",
                              status: widget.menuItemModel.status ?? "",
                              type: widget.menuItemModel.type ?? "",
                              upselling: widget.menuItemModel.upselling ?? "",
                              quantity: initialValue,
                              cookingStatus: "pending"));
                        }
                      },
                      child: const Icon(
                        Icons.remove,
                        size: 15,
                      )),
                  Text(initialValue.toString()),
                  InkWell(
                      onTap: () {
                        setState(() {
                          initialValue++;
                          cart.cartItems[index].quantity = initialValue;
                          cart.updateState();
                        });
                      },
                      child: const Icon(
                        Icons.add,
                        size: 15,
                      ))
                ],
              ),
      ),
    );
  }
}
