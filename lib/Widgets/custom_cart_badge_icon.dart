import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../Provider/cart_provider.dart';

class CustomCartBadgeIcon extends StatelessWidget {
  final String restaurantsKey;
  final String tableKey;
  final String name;
  final String phone;
  final String isTableClean;
  const CustomCartBadgeIcon({
    super.key,
    required this.restaurantsKey,
    required this.tableKey,
    required this.name,
    required this.phone,
    required this.isTableClean,
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
          Beamer.of(context).beamToNamed(
              "/customer-cart/$restaurantsKey,$tableKey,$name,$phone,$isTableClean");
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          height: 80,
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
    );
  }

  String getTotalPrice(List items) {
    double total = 0;
    for (var element in items) {
      total += double.parse(element["price"]) * element["quantity"];
    }
    return total.toString();
  }
}
