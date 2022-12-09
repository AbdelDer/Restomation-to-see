import 'package:beamer/beamer.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Widgets/custom_button.dart';

class CustomerOrderItemsView extends StatelessWidget {
  final String restaurantName;
  final String phone;
  final String tableKey;
  final String name;
  final String isTableClean;
  const CustomerOrderItemsView(
      {super.key,
      required this.restaurantName,
      required this.phone,
      required this.tableKey,
      required this.name,
      required this.isTableClean});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.db
          .ref()
          .child("order_items")
          .child(restaurantName)
          .child(phone)
          .limitToLast(1)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) =>
          orderItemView(context, snapshot),
    );
  }

  Widget orderItemView(
      BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (snapshot.hasError) {
      return const CustomText(
        text: "Error",
      );
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
        child: CustomText(text: "No Orders Yet !!"),
      );
    }
    Map orderItems = snapshot.data!.snapshot.value as Map;
    List orderItemsKeys = orderItems.keys.toList();
    List items = orderItems[orderItemsKeys[0]];

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
              text: getTotalPrice(items),
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
            itemCount: items.length,
            itemBuilder: (context, itemIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: myOrderedItems(context, items[itemIndex]),
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
                    Beamer.of(context).beamToNamed(
                        "/restaurants-menu-category/$restaurantName,$tableKey,$name,$phone,$isTableClean,yes,${orderItemsKeys[0]},${items.length}");
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

  Widget myOrderedItems(BuildContext context, Map data) {
    final ref = StorageService.storage.ref().child(data["image"]);
    return Row(
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
                data["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "₹${data["price"]} x ${data["quantity"]} = ${(double.parse(data["price"]) * data["quantity"])}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${data["type"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                text: data["description"],
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

  String getTotalPrice(List items) {
    double total = 0;
    for (var element in items) {
      total += double.parse(element["price"]) * element["quantity"];
    }
    return total.toString();
  }
}
