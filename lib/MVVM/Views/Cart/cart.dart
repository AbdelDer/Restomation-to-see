import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Views/Discount%20Page/discount_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Provider/cart_provider.dart';
import '../../../Widgets/custom_loader.dart';

class CartPage extends StatefulWidget {
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
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F0F5),
      appBar: BaseAppBar(
        appBarHeight: 60,
        title: 'Cart',
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Beamer.of(context).beamToNamed(
                "/restaurants-menu-category/${widget.restaurantsKey},${widget.tableKey},${widget.name},${widget.phone},${widget.isTableClean},${widget.addMoreItems},${widget.orderItemsKey},${widget.existingItemCount}");
          },
        ),
        widgets: [],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: (cart.cartItems.isNotEmpty)
                      ? Column(
                          children: [
                            for (int i = 0; i < cart.cartItems.length; i++) ...[
                              cartItemDisplay(context, cart.cartItems[i], cart)
                            ]
                          ],
                        )
                      : SizedBox(
                          width: size.width,
                          child: const CustomText(
                            text: "Your Cart is Empty",
                            textAlign: TextAlign.center,
                          ),
                        )),
              StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("menu_items")
                      .child(widget.restaurantsKey)
                      .orderByChild("category")
                      .equalTo("Water")
                      .onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
                    return menuItemsView(snapshot, cart);
                  }),
            ],
          ),
          Positioned(
            bottom: 0,
            child: bottomBar(size, context),
          )
        ],
      ),
    );
  }

  Container bottomBar(Size size, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(builder: (context) {
                Cart cart = context.watch<Cart>();
                return CustomText(
                  text: "₹${getTotalPrice(cart)}",
                  fontsize: 18,
                  fontWeight: FontWeight.bold,
                );
              }),
              const CustomText(
                text: "Total",
                fontsize: 12,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              )
            ],
          ),
          CustomButton(
              buttonColor: primaryColor,
              text: widget.addMoreItems == "yes" ? "Update Order" : "Order",
              textColor: kWhite,
              function: () async {
                KRoutes.push(
                    context,
                    DiscountPage(
                      restaurantsKey: widget.restaurantsKey,
                      tableKey: widget.tableKey,
                      name: widget.name,
                      isTableClean: widget.isTableClean,
                      phone: widget.phone,
                      addMoreItems: widget.addMoreItems,
                      orderItemsKey: widget.orderItemsKey,
                      existingItemCount: widget.existingItemCount,
                    ));
              }),
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
    final size = MediaQuery.of(context).size;
    var initialValue = data['quantity'];
    final ref = StorageService.storage.ref().child(data["image"]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.network(
                    'https://img.icons8.com/small/16/000000/vegetarian-food-symbol.png',
                    color: data["type"].toString().toLowerCase() == "veg"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.4,
                      child: CustomText(
                        text: '${data["name"]}',
                        maxLines: 2,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    CustomText(
                      text: data["instructions"] ?? "No instructions",
                      color: Colors.black45,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            qtyWidget(initialValue, data, cart),
            SizedBox(
              width: 80,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomText(
                  text: "₹${double.parse(data['price']) * data['quantity']}",
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        )
      ]),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 10),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           const Icon(
    //             Icons.adjust_rounded,
    //             color: Colors.green,
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             data["name"],
    //             style: const TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             "Rs. ${data["price"]} x ${data["quantity"]}",
    //             style: const TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           CustomText(
    //               text:
    //                   "total  ${double.parse(data["price"]) * data["quantity"]}"),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           const Text(
    //             "Instructions :",
    //             style: TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           CustomText(
    //             text: data["instructions"] ?? "No instructions",
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           SizedBox(
    //             height: 180,
    //             child: Stack(
    //               alignment: Alignment.center,
    //               children: [
    //                 FutureBuilder(
    //                     future: ref.getDownloadURL(),
    //                     builder:
    //                         (BuildContext context, AsyncSnapshot snapshot) {
    //                       if (snapshot.connectionState ==
    //                           ConnectionState.done) {
    //                         return Container(
    //                           width: 170,
    //                           height: 150,
    //                           decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(15),
    //                               boxShadow: const [
    //                                 BoxShadow(
    //                                     offset: Offset(0, 0),
    //                                     spreadRadius: 2,
    //                                     blurRadius: 2,
    //                                     color: Colors.black12)
    //                               ],
    //                               image: DecorationImage(
    //                                   image: NetworkImage(snapshot.data!),
    //                                   fit: BoxFit.cover)),
    //                         );
    //                       }
    //                       return Container(
    //                         width: 170,
    //                         height: 150,
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(15),
    //                           boxShadow: const [
    //                             BoxShadow(
    //                                 offset: Offset(0, 0),
    //                                 spreadRadius: 2,
    //                                 blurRadius: 2,
    //                                 color: Colors.black12)
    //                           ],
    //                         ),
    //                       );
    //                     }),
    //               ],
    //             ),
    //           ),
    //           const SizedBox(
    //             width: 20,
    //           ),
    //           InkWell(
    //               onTap: () {
    //                 cart.removeCartItem(data);
    //               },
    //               child: const Icon(Icons.delete)),
    //         ],
    //       )
    //     ],
    //   ),
    // );
  }

  Widget qtyWidget(initialValue, Map<dynamic, dynamic> data, Cart cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black26)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
              onTap: () {
                setState(() {
                  initialValue--;
                  data["quantity"] = initialValue;
                  cart.updateState();
                });
                if (initialValue == 0) {
                  cart.deleteCartItem(data);
                }
              },
              child: const Icon(
                Icons.remove,
                size: 15,
                color: primaryColor,
              )),
          const SizedBox(
            width: 8,
          ),
          CustomText(
            text: initialValue.toString(),
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                setState(() {
                  initialValue++;
                  data["quantity"] = initialValue;

                  cart.updateState();
                });
              },
              child: const Icon(
                Icons.add,
                size: 15,
                color: primaryColor,
              ))
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
                text: "Frequently bought together :",
                fontWeight: FontWeight.bold,
                fontsize: 15,
              ),
            )),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          height: 145,
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
                      Image.network(
                        'https://img.icons8.com/small/16/000000/vegetarian-food-symbol.png',
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
                          ),
                          Row(
                            children: [
                              Text(
                                "₹${foodItem["price"]}  ",
                                style: const TextStyle(
                                    color: kblack, fontWeight: FontWeight.bold),
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
