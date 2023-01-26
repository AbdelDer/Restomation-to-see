import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Customer%20Order%20Page/customer_order_item_display.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

class CustomerOrderPage extends StatelessWidget {
  final String restaurantsKey;
  final String tableKey;
  final String name;
  final String phone;
  const CustomerOrderPage(
      {super.key,
      required this.restaurantsKey,
      required this.tableKey,
      required this.name,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    Beamer.of(context).beamingHistory.clear();
    return Scaffold(
      backgroundColor: kBackground,
      appBar: BaseAppBar(
          title: "Bill", appBar: AppBar(), widgets: const [], appBarHeight: 40),
      body: StreamBuilder(
        stream: DatabaseService.db
            .ref()
            .child("orders")
            .child(restaurantsKey)
            .orderByChild("name")
            .equalTo(name)
            .limitToLast(1)
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
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
          Map? order = snapshot.data!.snapshot.value as Map;
          List orderKeys = order.keys.toList();
          String orderKey = orderKeys[0];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: kWhite),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CustomText(
                            text: "Assigned Waiter",
                            fontsize: 20,
                            color: kGrey,
                          ),
                          CustomText(
                            text: order[orderKey]["waiter"] ?? "none",
                            color: order[orderKey]["waiter"] == "none"
                                ? Colors.red
                                : Colors.green,
                            fontsize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Order Status :",
                            fontWeight: FontWeight.bold,
                            fontsize: 20,
                          ),
                          CustomText(
                            text: order[orderKey]["order_status"] ?? "none",
                            color: order[orderKey]["order_status"]
                                            .toString()
                                            .toLowerCase() ==
                                        "done" ||
                                    order[orderKey]["order_status"]
                                            .toString()
                                            .toLowerCase() ==
                                        "ready to deliver"
                                ? Colors.green
                                : Colors.red,
                            fontsize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: CustomerOrderItemsView(
                  phone: phone,
                  restaurantName: restaurantsKey,
                  name: name,
                  tableKey: tableKey,
                  isTableClean: order[orderKey]["isTableClean"],
                  order: order[orderKey] as Map,
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
