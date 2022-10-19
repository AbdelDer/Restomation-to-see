import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:restomation/MVVM/Views/Cart/cart.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../Provider/cart_provider.dart';
import '../Utils/app_routes.dart';

class CustomCartBadgeIcon extends StatelessWidget {
  const CustomCartBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();
    return GestureDetector(
        onTap: () {
          KRoutes.push(context, const CartPage());
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
