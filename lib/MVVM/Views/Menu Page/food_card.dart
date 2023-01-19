import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/add_to_cart.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../Repo/Storage Service/storage_service.dart';

class CustomFoodCard extends StatefulWidget {
  final Map data;
  final String? name;
  final String? phone;
  final String restaurantsKey;
  final String categoryName;
  final VoidCallback edit;
  final VoidCallback delete;
  final bool instructions;
  const CustomFoodCard({
    super.key,
    required this.data,
    required this.name,
    required this.phone,
    required this.restaurantsKey,
    required this.categoryName,
    required this.edit,
    required this.delete,
    this.instructions = true,
  });

  @override
  State<CustomFoodCard> createState() => _CustomFoodCardState();
}

class _CustomFoodCardState extends State<CustomFoodCard> {
  bool show = false;
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ref = StorageService.storage.ref().child(widget.data["image"]);
    bool isActive = false;
    if (widget.data["status"] == "available") {
      isActive = true;
    }
    widget.data["cookingStatus"] = "pending";
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.adjust_rounded,
                    color: widget.data["type"].toString().toLowerCase() == "veg"
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.data["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Rs. ${widget.data["price"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ExpandableText(
                    widget.data["description"] + "  ",
                    expandText: 'show more',
                    collapseText: 'show less',
                    maxLines: 2,
                    linkColor: primaryColor,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                      future: ref.getDownloadURL(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            width: 150,
                            height: 120,
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
                          width: 150,
                          height: 120,
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
                  if (widget.name != null)
                    Positioned(
                      bottom: 5,
                      child: AddToCart(
                        foodData: widget.data,
                        restaurantsKey: widget.restaurantsKey,
                        categoryName: widget.categoryName,
                        upscale: widget.instructions,
                      ),
                    ),
                  if (widget.name == null)
                    Positioned(
                        top: 20,
                        right: 10,
                        child: InkWell(
                          onTap: () {
                            widget.data["upselling"] == true
                                ? DatabaseService.db
                                    .ref()
                                    .child("menu_items")
                                    .child(widget.restaurantsKey)
                                    .child(widget.data["key"])
                                    .update({"upselling": false})
                                : DatabaseService.db
                                    .ref()
                                    .child("menu_items")
                                    .child(widget.restaurantsKey)
                                    .child(widget.data["key"])
                                    .update({"upselling": true});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 2,
                                    color: Colors.grey.shade400),
                              ],
                            ),
                            child: Icon(
                              widget.data["upselling"] == true
                                  ? Icons.upload_sharp
                                  : Icons.upload_outlined,
                              color: widget.data["upselling"] == true
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                        ))
                ],
              ),
            )
          ],
        ),
        if (widget.name == null)
          StatefulBuilder(builder: (context, refreshState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  color: primaryColor,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: widget.edit,
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  color: Colors.red,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: widget.delete,
                ),
                const SizedBox(
                  width: 10,
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    if (value == true) {
                      DatabaseService.db
                          .ref()
                          .child("menu_items")
                          .child(widget.restaurantsKey)
                          .child(widget.data["key"])
                          .update({"status": "available"});
                    } else {
                      DatabaseService.db
                          .ref()
                          .child("menu_items")
                          .child(widget.restaurantsKey)
                          .child(widget.data["key"])
                          .update({"status": "unavailable"});
                    }
                  },
                ),
              ],
            );
          }),
        if (widget.name != null && widget.instructions == true)
          StatefulBuilder(
            builder: (BuildContext context, refreshState) {
              Cart cart = context.watch<Cart>();
              int index = cart.cartItems.indexWhere((element) =>
                  element["name"].toString().toLowerCase() ==
                  widget.data["name"].toString().toLowerCase());
              if (show == false) {
                return InkWell(
                  onTap: () {
                    if (index != -1) {
                      refreshState(() {
                        show = true;
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please enter the item in Cart first");
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.add,
                        color: index != -1 ? primaryColor : kGrey,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomText(
                        text: "Instructions",
                        color: index != -1 ? primaryColor : kGrey,
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          refreshState(() {
                            controller.clear();
                            show = false;
                          });
                        },
                        child: const Icon(Icons.cancel)),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FormTextField(
                          controller: controller,
                          suffixIcon: const Icon(Icons.text_fields)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          cart.updateCartItem(widget.data, controller.text);
                          refreshState(() {
                            show = false;
                          });
                        },
                        child: const Icon(Icons.send))
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
