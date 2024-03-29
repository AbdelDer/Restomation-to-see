import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Widgets/add_to_cart.dart';
import '../../Repo/Storage Service/storage_service.dart';

class CustomerMenuFoodCard extends StatefulWidget {
  final MenuItemModel item;
  const CustomerMenuFoodCard({super.key, required this.item});

  @override
  State<CustomerMenuFoodCard> createState() => _CustomerMenuFoodCardState();
}

class _CustomerMenuFoodCardState extends State<CustomerMenuFoodCard> {
  bool show = false;
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ref = StorageService.storage.ref().child(widget.item.imagePath ?? "");

    return SizedBox(
      height: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
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
                      widget.item.name ?? "No name",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "₹${widget.item.price ?? "0"}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${widget.item.type}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomText(
                      text: widget.item.description ?? "No description",
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
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
                    Positioned(
                        bottom: 5,
                        child: AddToCart(
                          menuItemModel: widget.item,
                        )),
                  ],
                ),
              )
            ],
          ),
          // if (widget.name == null)
          //   StatefulBuilder(builder: (context, refreshState) {
          //     return Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         IconButton(
          //           color: primaryColor,
          //           icon: const Icon(
          //             Icons.edit_outlined,
          //           ),
          //           onPressed: widget.edit,
          //         ),
          //         const SizedBox(
          //           width: 10,
          //         ),
          //         IconButton(
          //           color: Colors.red,
          //           icon: const Icon(
          //             Icons.delete_outline,
          //           ),
          //           onPressed: widget.delete,
          //         ),
          //         const SizedBox(
          //           width: 10,
          //         ),
          //         Switch(
          //           value: isActive,
          //           onChanged: (value) {
          //             if (value == true) {
          //               DatabaseService.db
          //                   .ref()
          //                   .child("restaurants")
          //                   .child(widget.restaurantsKey)
          //                   .child("menu")
          //                   .child(widget.categoryKey)
          //                   .child("items")
          //                   .child(widget.data["key"])
          //                   .update({"status": "available"});
          //             } else {
          //               DatabaseService.db
          //                   .ref()
          //                   .child("restaurants")
          //                   .child(widget.restaurantsKey)
          //                   .child("menu")
          //                   .child(widget.categoryKey)
          //                   .child("items")
          //                   .child(widget.data["key"])
          //                   .update({"status": "unavailable"});
          //             }
          //           },
          //         ),
          //       ],
          //     );
          //   }),
          // if (widget.name != null)
          //   StatefulBuilder(
          //     builder: (BuildContext context, refreshState) {
          //       Cart cart = context.watch<Cart>();
          //       int index = cart.cartItems.indexWhere((element) =>
          //           element["name"].toString().toLowerCase() ==
          //           widget.data["name"].toString().toLowerCase());
          //       if (show == false) {
          //         return InkWell(
          //           onTap: () {
          //             if (index != -1) {
          //               refreshState(() {
          //                 show = true;
          //               });
          //             } else {
          //               Fluttertoast.showToast(
          //                   msg: "Please enter the item in Cart first");
          //             }
          //           },
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.end,
          //             children: [
          //               Icon(
          //                 Icons.add,
          //                 color: index != -1 ? primaryColor : kGrey,
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               CustomText(
          //                 text: "Instructions",
          //                 color: index != -1 ? primaryColor : kGrey,
          //               ),
          //             ],
          //           ),
          //         );
          //       }

          //     return Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //       child: Row(
          //         children: [
          //           InkWell(
          //               onTap: () {
          //                 refreshState(() {
          //                   controller.clear();
          //                   show = false;
          //                 });
          //               },
          //               child: const Icon(Icons.cancel)),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //             child: FormTextField(
          //                 controller: controller,
          //                 suffixIcon: const Icon(Icons.text_fields)),
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //               onTap: () {
          //                 cart.updateCartItem(widget.data, controller.text);
          //                 refreshState(() {
          //                   show = false;
          //                 });
          //               },
          //               child: const Icon(Icons.send))
          //         ],
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
