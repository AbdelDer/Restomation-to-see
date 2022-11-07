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
    return GestureDetector(
        onTap: () {
          Beamer.of(context).beamToNamed(
              "/customer-cart/$restaurantsKey,$tableKey,$name,$phone,$isTableClean");
        },
        child: Row(
          children: [
            const Icon(CupertinoIcons.shopping_cart),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: cart.cartItems.isNotEmpty ? 1 : 0,
              child: Visibility(
                visible: cart.cartItems.isNotEmpty ? true : false,
                child: Container(
                  width: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: CustomText(
                    text: cart.cartItems.length.toString(),
                    color: kWhite,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
