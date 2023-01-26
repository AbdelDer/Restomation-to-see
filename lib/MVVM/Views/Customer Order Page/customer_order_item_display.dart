import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Models/Cart%20Item%20Model/cart_item_model.dart';
import 'package:restomation/MVVM/Models/Customer%20Model/customer_order_model.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Widgets/custom_button.dart';

class CustomerOrderItemsView extends StatelessWidget {
  final CustomerOrderModel order;
  const CustomerOrderItemsView({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return orderItemView(
      context,
      order,
    );
  }

  Widget orderItemView(
    BuildContext context,
    CustomerOrderModel order,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText(
              text: "Total Bill",
              fontWeight: FontWeight.bold,
              fontsize: 20,
            ),
            CustomText(
              text: getTotalPrice(order.orderItems ?? []),
              fontsize: 20,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          thickness: 1,
          indent: 100,
          endIndent: 100,
          color: kblack,
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: order.orderItems?.length ?? 0,
            itemBuilder: (context, itemIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: myOrderedItems(context, order.orderItems![itemIndex]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Add more items",
                  textColor: kWhite,
                  function: () {
                    context.push("/customer-menu-page");
                  }),
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Pay",
                  textColor: kWhite,
                  function: () {
                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.confirm,
                        showCancelBtn: true,
                        width: 300,
                        text: "How do You want to pay?",
                        cancelBtnText: "Cash",
                        confirmBtnText: "Card");
                  })
            ],
          ),
        ),
      ],
    );
  }

  Widget myOrderedItems(BuildContext context, CartItemModel item) {
    final ref = StorageService.storage.ref().child(item.imagePath);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.adjust_rounded,
                    color: item.type.toString().toLowerCase() == "veg"
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomText(
                    text: item.cookingStatus,
                    color: item.cookingStatus == "pending"
                        ? Colors.red
                        : item.cookingStatus == "cooking"
                            ? primaryColor
                            : item.cookingStatus == "ready"
                                ? Colors.amber
                                : item.cookingStatus == "delivered"
                                    ? Colors.green
                                    : Colors.red,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "₹${item.price} x ${item.quantity} = ${(double.parse(item.price) * item.quantity)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                item.type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                text: item.description,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: FutureBuilder(
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
        )
      ],
    );
  }

  String getTotalPrice(List<CartItemModel> items) {
    double total = 0;
    for (var element in items) {
      total += double.parse(element.price) * element.quantity;
    }
    return total.toString();
  }
}
