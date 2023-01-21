import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../Provider/cart_provider.dart';

class CustomCartBadgeIcon extends StatelessWidget {
  const CustomCartBadgeIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();
    String price = getTotalPrice(cart.cartItems);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: cart.cartItems.isNotEmpty ? 1 : 0,
      child: GestureDetector(
        onTap: () {
          context.push("/cart-page");
        },
        child: Visibility(
          visible: cart.cartItems.isNotEmpty ? true : false,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(10),
            height: 85,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "${cart.cartItems.length} Items | ₹$price",
                      color: kWhite,
                      fontsize: 16,
                    ),
                    const CustomText(
                      text: "Extra charges may apply",
                      fontsize: 10,
                      color: kWhite,
                    )
                  ],
                ),
                const CustomText(
                  text: "View Cart",
                  color: kWhite,
                  fontsize: 16,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTotalPrice(List<CartItemModel> items) {
    double total = 0;
    for (var element in items) {
      total += double.parse(element.price) * element.quantity;
    }
    return total.toString();
  }
}
