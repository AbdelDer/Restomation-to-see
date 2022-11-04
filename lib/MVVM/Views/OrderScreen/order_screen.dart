import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Views/OrderScreen/all_waiters_display.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_item_display.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';
import '../../Repo/Database Service/database_service.dart';

class OrderScreen extends StatefulWidget {
  final String restaurantsKey;
  const OrderScreen({super.key, required this.restaurantsKey});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: widget.restaurantsKey,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50,
          automaticallyImplyLeading: true,
        ),
        body: Center(
            child: StreamBuilder(
          stream: DatabaseService.db
              .ref()
              .child("restaurants")
              .child(widget.restaurantsKey)
              .child("orders")
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            return orderDisplayView(snapshot);
          },
        )));
  }

  Widget orderDisplayView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
        child: CustomText(text: "No Orders Yet !!"),
      );
    }
    Map? order = (snapshot.data as DatabaseEvent).snapshot.value as Map;
    List tables = order.keys.toList();
    List orderList = order.values.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "All Orders :",
            fontWeight: FontWeight.bold,
            fontsize: 25,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  (snapshot.data as DatabaseEvent).snapshot.children.length,
              itemBuilder: (context, index) {
                bool isOpened = false;
                return listExpansionView(isOpened, tables, index, orderList);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listExpansionView(
      bool isOpened, List tables, int index, List orderList) {
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
                    text: tables[index],
                    fontsize: 15,
                  ),
                ],
              ),
            ),
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: (orderList[index]["waiter"] == "none") ? 310 : 250,
                width: double.infinity,
                child: Column(
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
                                  text: "${orderList[index]["name"]} \n"
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 18)),
                              const TextSpan(text: "Is the table cleaned : "),
                              TextSpan(
                                  text: "${orderList[index]["isTableClean"]}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: orderList[index]["isTableClean"] ==
                                            "yes"
                                        ? Colors.green
                                        : Colors.red,
                                  )),
                            ]),
                          ),
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(text: "Assigned Waiter : "),
                              TextSpan(
                                  text: "${orderList[index]["waiter"]}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: orderList[index]["waiter"] != "none"
                                        ? Colors.green
                                        : Colors.red,
                                  )),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (orderList[index]["items"] as Map).length,
                        itemBuilder: (context, itemIndex) {
                          List foodItem = (orderList[index]["items"] as Map)
                              .values
                              .toList();
                          return OrderItemDisplay(data: foodItem[itemIndex]);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (orderList[index]["waiter"] == "none")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            buttonColor: primaryColor,
                            text: "Assign Order",
                            textColor: kWhite,
                            function: () {
                              showDialog(
                                context: context,
                                builder: (context) => AllWaiterDisplay(
                                  restaurantKey: widget.restaurantsKey,
                                  tableKey: tables[index],
                                ),
                              );
                            },
                            width: 130,
                            height: 40,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          CustomButton(
                            buttonColor: primaryColor,
                            text: "Cancel Order",
                            textColor: kWhite,
                            function: () {},
                            width: 130,
                            height: 40,
                          ),
                        ],
                      ),
                    if (orderList[index]["waiter"] == "none")
                      const SizedBox(
                        height: 20,
                      ),
                  ],
                ),
              ),
            ],
          ));
    });
  }
}
