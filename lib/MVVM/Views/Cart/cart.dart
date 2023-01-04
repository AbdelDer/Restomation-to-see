import 'package:beamer/beamer.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Provider/cart_provider.dart';
import '../../../Widgets/custom_loader.dart';

class CartPage extends StatelessWidget {
  final String restaurantsKey;
  final String tableKey;
  final String name;
  final String isTableClean;
  final String phone;
  final String? addMoreItems;
  final String? orderItemsKey;
  final String? existingItemCount;
  const CartPage(
      {super.key,
      required this.restaurantsKey,
      required this.tableKey,
      required this.name,
      required this.phone,
      required this.isTableClean,
      required this.addMoreItems,
      required this.orderItemsKey,
      required this.existingItemCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "Cart",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(builder: (context) {
              Cart cart = context.watch<Cart>();
              return ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  return cartItemDisplay(context, cart.cartItems[index], cart);
                },
              );
            }),
          ),
          StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child("menu_items")
                  .child(restaurantsKey)
                  .orderByChild("upselling")
                  .equalTo(true)
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
                return Builder(builder: (context) {
                  Cart cart = context.watch<Cart>();
                  return menuItemsView(snapshot, cart);
                });
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: "Total :",
                  fontsize: 25,
                  fontWeight: FontWeight.bold,
                ),
                Builder(builder: (context) {
                  Cart cart = context.watch<Cart>();
                  return CustomText(
                    text: "Rs.  ${getTotalPrice(cart)}",
                    fontsize: 25,
                    fontWeight: FontWeight.bold,
                  );
                })
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Builder(builder: (context) {
            Cart cart = context.watch<Cart>();
            return CustomButton(
                buttonColor: primaryColor,
                text: addMoreItems == "yes" ? "Update Order" : "Order",
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
                });
          }),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  String getTotalPrice(Cart cart) {
    double total = 0;
    for (var element in cart.cartItems) {
      total += double.parse(element["price"]) * element["quantity"];
    }
    return total.toString();
  }

  Widget cartItemDisplay(BuildContext context, Map data, Cart cart) {
    final ref = StorageService.storage.ref().child(data["image"]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.adjust_rounded,
                color: Colors.green,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Rs. ${data["price"]} x ${data["quantity"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                  text:
                      "total  ${double.parse(data["price"]) * data["quantity"]}"),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Instructions :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                text: data["instructions"] ?? "No instructions",
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FutureBuilder(
                        future: ref.getDownloadURL(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              width: 170,
                              height: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(0, 0),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        color: Colors.black12)
                                  ],
                                  image: DecorationImage(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.cover)),
                            );
                          }
                          return Container(
                            width: 170,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    color: Colors.black12)
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () {
                    cart.removeCartItem(data);
                  },
                  child: const Icon(Icons.delete)),
            ],
          )
        ],
      ),
    );
  }

  Widget menuItemsView(AsyncSnapshot<DatabaseEvent?> snapshot, Cart cart) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
          child: CustomText(text: "No upselling items added yet !!"));
    }
    Map allrestaurantsMenuItems = snapshot.data!.snapshot.value as Map;
    List categoriesListItems = allrestaurantsMenuItems.keys.toList();

    categoriesListItems =
        allrestaurantsMenuItems.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsMenuItems[element]["status"].toString().toLowerCase();
      const status = "available";
      return categoryTitle == status;
    }).toList();

    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomText(
                text: "Special offers only for you :",
                fontWeight: FontWeight.bold,
                fontsize: 15,
              ),
            )),
        SizedBox(
          height: 130,
          child: ListView.separated(
            itemCount: categoriesListItems.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              String key = categoriesListItems[index];
              Map foodItem = allrestaurantsMenuItems[key] as Map;
              foodItem["key"] = key;
              int index2 = cart.cartItems.indexWhere((element) =>
                  element["name"].toString().toLowerCase() ==
                  foodItem["name"].toString().toLowerCase());

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.adjust_rounded,
                        color:
                            foodItem["type"].toString().toLowerCase() == "veg"
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: foodItem["name"],
                            fontWeight: FontWeight.bold,
                          ),
                          Row(
                            children: [
                              Text(
                                "Rs. ${foodItem["price"]}  ",
                                style: const TextStyle(
                                  color: kGrey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              CustomText(
                                text:
                                    "Rs. ${getDiscountedPrice(foodItem["price"])}  ",
                                fontWeight: FontWeight.bold,
                              ),
                              const CustomText(
                                text: "( You save Rs. 20 )",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Checkbox(
                      value: index2 != -1 ? true : false,
                      onChanged: (value) {
                        if (index2 == -1) {
                          foodItem["quantity"] = 1;
                          foodItem["price"] =
                              getDiscountedPrice(foodItem["price"]);
                          cart.addCartItem(foodItem);
                        } else {
                          cart.removeCartItem(foodItem);
                        }
                      })
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: kGrey,
              // indent: 100,
              // endIndent: 100,
              thickness: 1,
            ),
          ),
        ),
      ],
    );
  }

  String getDiscountedPrice(String price) {
    double totalPrice = double.parse(price);
    totalPrice = totalPrice - 20;
    return "$totalPrice";
  }
}
