import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_item_display.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Repo/Database Service/database_service.dart';

class FilteredOrderScreen extends StatefulWidget {
  final String restaurantsKey;
  final String filteredOrderType;
  const FilteredOrderScreen(
      {super.key,
      required this.restaurantsKey,
      required this.filteredOrderType});

  @override
  State<FilteredOrderScreen> createState() => _FilteredOrderScreenState();
}

class _FilteredOrderScreenState extends State<FilteredOrderScreen> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.db
          .ref()
          .child(widget.filteredOrderType)
          .child(widget.restaurantsKey)
          .child(formatter.format(DateTime.now()))
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        return orderDisplayView(snapshot);
      },
    );
  }

  Widget orderDisplayView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
        child: CustomText(text: "No orders Yet !!"),
      );
    }
    Map? order = (snapshot.data as DatabaseEvent).snapshot.value as Map;
    List orderKeys = order.keys.toList();

    return ListView.builder(
      itemCount: orderKeys.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        String key = orderKeys[index];
        bool isOpened = false;
        Map subOrder = order[key];
        List subOrderKeys = subOrder.keys.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            CustomText(text: key),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
                itemCount: subOrderKeys.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String subKey = subOrderKeys[index];
                  return listExpansionView(
                      isOpened, orderKeys, index, (subOrder[subKey] as Map));
                }),
          ],
        );
      },
    );
  }

  Widget listExpansionView(
      bool isOpened, List orderKeys, int index, Map orderDetail) {
    return StatefulBuilder(builder: (context, changeState) {
      return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(20)),
          child: ExpansionTile(
            onExpansionChanged: (value) {
              changeState(() {
                isOpened = value;
              });
            },
            title: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: (isOpened) ? Colors.grey.shade300 : Colors.transparent,
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Icon(
                    Icons.table_bar,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomText(
                    text: orderDetail["table_name"],
                    fontsize: 15,
                  ),
                ],
              ),
            ),
            children: [
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${orderDetail["name"]} \n".toUpperCase(),
                                style: const TextStyle(fontSize: 18)),
                            if (orderDetail["table_name"]
                                    .toString()
                                    .toLowerCase() !=
                                "take away")
                              const TextSpan(text: "Is the table cleaned : "),
                            if (orderDetail["table_name"]
                                    .toString()
                                    .toLowerCase() !=
                                "take away")
                              TextSpan(
                                  text: "${orderDetail["isTableClean"]}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: orderDetail["isTableClean"] == "yes"
                                        ? Colors.green
                                        : Colors.red,
                                  )),
                          ]),
                        ),
                        if (orderDetail["table_name"]
                                .toString()
                                .toLowerCase() !=
                            "take away")
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(text: "Assigned Waiter : "),
                              TextSpan(
                                  text:
                                      "${orderDetail["waiter"]}".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: orderDetail["waiter"] != "none"
                                        ? Colors.green
                                        : Colors.red,
                                  )),
                            ]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 400,
                      child: OrderItemDisplay(
                        phone: orderDetail["phone"],
                        restaurantName: widget.restaurantsKey,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ));
    });
  }
}
