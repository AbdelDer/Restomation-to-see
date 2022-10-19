import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/Provider/cart_provider.dart';

class AddToCart extends StatefulWidget {
  final Map foodData;
  const AddToCart({super.key, required this.foodData});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int initialValue = 0;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (initialValue == 0) {
          setState(() {
            initialValue++;
          });
          widget.foodData["quantity"] = initialValue;
          context.read<Cart>().addCartItem(widget.foodData);
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
                          widget.foodData["quantity"] = initialValue;
                          context.read<Cart>().deleteCartItem(widget.foodData);
                        });
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
                        });
                        widget.foodData["quantity"] = initialValue;
                        context.read<Cart>().addCartItem(widget.foodData);
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
