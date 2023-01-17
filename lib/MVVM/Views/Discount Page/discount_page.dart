import 'package:beamer/beamer.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';

import '../../../Provider/cart_provider.dart';
import '../../../Widgets/custom_loader.dart';
import '../../../Widgets/custom_text.dart';
import '../Menu Page/food_card.dart';

class DiscountPage extends StatelessWidget {
  final String restaurantsKey;
  final String tableKey;
  final String name;
  final String isTableClean;
  final String phone;
  final String? addMoreItems;
  final String? orderItemsKey;
  final String? existingItemCount;
  const DiscountPage(
      {super.key,
      required this.restaurantsKey,
      required this.tableKey,
      required this.name,
      required this.isTableClean,
      required this.phone,
      this.addMoreItems,
      this.orderItemsKey,
      this.existingItemCount});

  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();
    return Scaffold(
      appBar: BaseAppBar(
          title: "Special Dishes",
          appBar: AppBar(),
          automaticallyImplyLeading: true,
          leading: InkWell(
            onTap: () {
              KRoutes.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: kblack,
            ),
          ),
          widgets: const [],
          appBarHeight: 50),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomButton(
                buttonColor: primaryColor,
                text: "Checkout",
                textColor: kWhite,
                function: () async {
                  if (addMoreItems == "yes") {
                    CoolAlert.show(
                        context: context, type: CoolAlertType.loading);

                    await DatabaseService()
                        .updateOrderItems(restaurantsKey, cart.cartItems, phone,
                            orderItemsKey!, int.parse(existingItemCount!), name)
                        .then((value) {
                      KRoutes.pop(context);
                      Fluttertoast.showToast(msg: "Ordered Successfully");
                      cart.clearCart();
                      Beamer.of(context).beamToReplacementNamed(
                          "/customer-order/$restaurantsKey,$tableKey,$name,$phone");
                    });
                  } else {
                    CoolAlert.show(
                        context: context, type: CoolAlertType.loading);
                    Map data = {
                      "name": name,
                      "phone": phone,
                      "table_name": tableKey,
                      "order_status": "pending",
                      "isTableClean": isTableClean,
                      "hasNewItems": false,
                      "waiter": "none"
                    };
                    await DatabaseService()
                        .createOrder(restaurantsKey, tableKey, data,
                            cart.cartItems, phone)
                        .then((value) {
                      KRoutes.pop(context);
                      Fluttertoast.showToast(msg: "Ordered Successfully");
                      cart.clearCart();
                      Beamer.of(context).beamToReplacementNamed(
                          "/customer-order/$restaurantsKey,$tableKey,$name,$phone");
                    });
                  }
                }),
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("menu_items")
              .child(restaurantsKey)
              .orderByChild("category")
              .equalTo("Specials")
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
            return menuItemsView(
              snapshot,
            );
          }),
    );
  }

  String getTotalPrice(Cart cart) {
    double total = 0;
    for (var element in cart.cartItems) {
      total += double.parse(element["price"]) * element["quantity"];
    }
    return total.toString();
  }

  Widget menuItemsView(AsyncSnapshot<DatabaseEvent?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
          child: CustomText(text: "No Specials items added yet !!"));
    }
    Map allrestaurantsMenuItems = snapshot.data!.snapshot.value as Map;
    List categoriesListItems = allrestaurantsMenuItems.keys.toList();

    List suggestions = allrestaurantsMenuItems.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsMenuItems[element]["status"].toString().toLowerCase();
      const status = "available";
      return categoryTitle == status;
    }).toList();

    suggestions = allrestaurantsMenuItems.keys.toList().where((element) {
      final categoryTitle = allrestaurantsMenuItems[element]["upselling"]
          .toString()
          .toLowerCase();
      const status = "false";
      return categoryTitle == status;
    }).toList();

    categoriesListItems = suggestions;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: categoriesListItems.length,
      itemBuilder: (context, index) {
        String key = categoriesListItems[index];
        Map foodItem = allrestaurantsMenuItems[key] as Map;
        foodItem["key"] = key;

        return Column(
          children: [
            CustomFoodCard(
              data: foodItem,
              name: name,
              phone: phone,
              restaurantsKey: restaurantsKey,
              categoryName: "Specials",
              delete: () {},
              edit: () {},
            ),
            if ((index + 1) == categoriesListItems.length)
              const SizedBox(
                height: 100,
              )
          ],
        );
      },
    );
  }
}
