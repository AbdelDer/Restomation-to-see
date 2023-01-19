import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../MVVM/Repo/Storage Service/storage_service.dart';
import '../Utils/app_routes.dart';
import 'custom_button.dart';

class AddToCart extends StatefulWidget {
  final Map foodData;
  final String categoryName;
  final String restaurantsKey;
  final bool upscale;
  const AddToCart(
      {super.key,
      required this.foodData,
      required this.categoryName,
      required this.restaurantsKey,
      this.upscale = true});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int initialValue = 0;
  @override
  Widget build(BuildContext context) {
    final ref = StorageService.storage.ref().child(widget.foodData["image"]);
    Cart cart = context.watch<Cart>();
    int index = cart.cartItems.indexWhere((element) =>
        element["name"].toString().toLowerCase() ==
        widget.foodData["name"].toString().toLowerCase());
    if (index != -1) {
      initialValue = cart.cartItems[index]["quantity"];
    }

    return InkWell(
      onTap: () {
        if (widget.upscale) {
          showCustomDialogue(ref);
        } else if (initialValue == 0) {
          setState(() {
            initialValue++;
          });
          Cart cart = context.read<Cart>();
          widget.foodData["quantity"] = 1;
          cart.addCartItem(widget.foodData);
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
        child: (initialValue == 0)
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
                          cart.cartItems[index]["quantity"] = initialValue;
                          cart.updateState();
                        });
                        if (initialValue == 0) {
                          cart.deleteCartItem(widget.foodData);
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
                          cart.cartItems[index]["quantity"] = initialValue;

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

  void showCustomDialogue(Reference ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        int quantity = 1;

        return Container(
          color: kGrey.shade200,
          height: 700,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: kWhite,
                child: Row(
                  children: [
                    FutureBuilder(
                        future: ref.getDownloadURL(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              width: 70,
                              height: 70,
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
                            width: 70,
                            height: 70,
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        widget.foodData["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor, width: 1)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                                onTap: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                child: const Icon(
                                  Icons.remove,
                                  color: primaryColor,
                                  size: 15,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              quantity.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: primaryColor,
                                  size: 15,
                                ))
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref()
                        .child("menu_items")
                        .child(widget.restaurantsKey)
                        .orderByChild("upselling")
                        .equalTo(true)
                        .onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
                      return Builder(builder: (context) {
                        Cart cart = context.watch<Cart>();
                        return menuItemsView(
                            snapshot, cart, widget.foodData["name"]);
                      });
                    }),
              ),
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Add Item",
                  textColor: kWhite,
                  function: () {
                    Cart cart = context.read<Cart>();
                    widget.foodData["quantity"] = quantity;
                    cart.addCartItem(widget.foodData);
                    KRoutes.pop(context);
                  }),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget menuItemsView(
      AsyncSnapshot<DatabaseEvent?> snapshot, Cart cart, String name) {
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
      final categoryStatus =
          allrestaurantsMenuItems[element]["status"].toString().toLowerCase();
      final categoryName =
          allrestaurantsMenuItems[element]["name"].toString().toLowerCase();
      final categoryCategory =
          allrestaurantsMenuItems[element]["category"].toString().toLowerCase();
      const status = "available";
      return categoryStatus == status &&
          categoryName != name.toLowerCase() &&
          categoryCategory != widget.categoryName.toLowerCase();
    }).toList();

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(15)),
      child: Column(
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
          Expanded(
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
                foodItem["cookingStatus"] = "pending";
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
                            Text(
                              foodItem["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                thickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getDiscountedPrice(String price) {
    double totalPrice = double.parse(price);
    totalPrice = totalPrice - 20;
    return totalPrice.toStringAsFixed(0);
  }
}
