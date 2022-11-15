import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Widgets/custom_text.dart';

class CustomerOrderItemsView extends StatelessWidget {
  final String restaurantName;
  final String name;
  const CustomerOrderItemsView(
      {super.key, required this.restaurantName, required this.name});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.db
          .ref()
          .child("order_items")
          .child(restaurantName)
          .child(name)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) =>
          orderItemView(snapshot),
    );
  }

  Widget orderItemView(AsyncSnapshot<DatabaseEvent> snapshot) {
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
    Map? orderItems = snapshot.data!.snapshot.value as Map;
    List orderItemsKeys = orderItems.keys.toList();
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
              text: getTotalPrice(orderItems.values.toList()),
              fontsize: 20,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orderItemsKeys.length,
            itemBuilder: (context, itemIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: myOrderedItems(
                    context, orderItems[orderItemsKeys[itemIndex]]),
              );
            },
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