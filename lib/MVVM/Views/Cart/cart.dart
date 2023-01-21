import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Provider/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Cart cart = context.watch<Cart>();

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
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                return cartItemDisplay(context, cart.cartItems[index], cart);
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
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
                CustomText(
                  text: getTotalPrice(cart),
                  fontsize: 25,
                  fontWeight: FontWeight.bold,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomButton(
              buttonColor: primaryColor,
              text: "Order",
              textColor: kWhite,
              function: () async {
                // if (addMoreItems == "yes") {
                //   CoolAlert.show(context: context, type: CoolAlertType.loading);

                //   await DatabaseService()
                //       .updateOrderItems(restaurantsKey, cart.cartItems, phone,
                //           orderItemsKey!, int.parse(existingItemCount!))
                //       .then((value) {
                //     KRoutes.pop(context);
                //     Fluttertoast.showToast(msg: "Ordered Successfully");

                //     Beamer.of(context).beamToReplacementNamed(
                //         "/customer-order/$restaurantsKey,$tableKey,$name,$phone");
                //   });
                // } else {
                //   CoolAlert.show(context: context, type: CoolAlertType.loading);
                //   Map<String, Object> data = {
                //     "name": name,
                //     "phone": phone,
                //     "table_name": tableKey,
                //     "order_status": "pending",
                //     "isTableClean": isTableClean,
                //     "waiter": "none"
                //   };
                //   await DatabaseService()
                //       .createOrder(
                //           restaurantsKey, tableKey, data, cart.cartItems, phone)
                //       .then((value) {
                //     KRoutes.pop(context);
                //     Fluttertoast.showToast(msg: "Ordered Successfully");

                //     Beamer.of(context).beamToReplacementNamed(
                //         "/customer-order/$restaurantsKey,$tableKey,$name,$phone");
                //   });
                // }
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
      total += double.parse(element.price) * element.quantity;
    }
    return total.toString();
  }

  Widget cartItemDisplay(BuildContext context, CartItemModel data, Cart cart) {
    final ref = StorageService.storage.ref().child(data.imagePath);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                data.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "₹${data.price} x ${data.quantity}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                  text: "total  ${double.parse(data.price) * data.quantity}"),
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
                text: data.instructions ?? "No instructions",
              ),
              const SizedBox(
                height: 10,
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
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
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
        InkWell(
            onTap: () {
              cart.deleteCartItem(data);
            },
            child: const Icon(Icons.delete))
      ],
    );
  }
}
