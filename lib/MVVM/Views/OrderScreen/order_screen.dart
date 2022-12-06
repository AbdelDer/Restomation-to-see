import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:restomation/MVVM/Views/OrderScreen/all_waiters_display.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_item_display.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Utils/app_routes.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_alert.dart';
import '../../../Widgets/custom_button.dart';
import '../../Repo/Database Service/database_service.dart';

class OrderScreen extends StatefulWidget {
  final String restaurantsKey;
  const OrderScreen({super.key, required this.restaurantsKey});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
              .child("orders")
              .child(widget.restaurantsKey)
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
    List orderKeys = order.keys.toList();

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
              itemCount: orderKeys.length,
              itemBuilder: (context, index) {
                String key = orderKeys[index];
                bool isOpened = false;
                return listExpansionView(
                    isOpened, orderKeys, index, (order[key] as Map));
              },
            ),
          ),
        ],
      ),
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
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        buttonColor: primaryColor,
                        text: (orderDetail["table_name"]
                                    .toString()
                                    .toLowerCase() ==
                                "take away")
                            ? "Accept Order"
                            : (orderDetail["waiter"] == "none")
                                ? "Assign Order"
                                : "Free Table",
                        textColor: kWhite,
                        function: () async {
                          if (orderDetail["table_name"]
                                  .toString()
                                  .toLowerCase() ==
                              "take away") {
                            Alerts.customLoadingAlert(context);
                            await DatabaseService.db
                                .ref()
                                .child("orders")
                                .child(widget.restaurantsKey)
                                .child(orderKeys[index])
                                .update({"order_status": "preparing"}).then(
                                    (value) => KRoutes.pop(context));
                          } else if (orderDetail["waiter"] == "none") {
                            showDialog(
                              context: context,
                              builder: (context) => AllWaiterDisplay(
                                restaurantKey: widget.restaurantsKey,
                                tableKey: orderKeys[index],
                              ),
                            );
                          } else if (orderDetail["order_status"] ==
                              "delivered") {
                            DatabaseService.db
                                .ref()
                                .child("orders")
                                .child(widget.restaurantsKey)
                                .child(orderKeys[index])
                                .remove();
                            DatabaseService.db
                                .ref()
                                .child("completed-orders")
                                .child(widget.restaurantsKey)
                                .child(formatter.format(DateTime.now()))
                                .child(orderDetail["phone"])
                                .push()
                                .update({
                              "name": orderDetail["name"],
                              "phone": orderDetail["phone"],
                              "table_name": orderDetail["table_name"],
                              "order_status": "completed",
                              "isTableClean": orderDetail["isTableClean"],
                              "waiter": orderDetail["waiter"]
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "You cannot free the table until it is delivered");
                          }
                        },
                        width: 130,
                        height: 40,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomButton(
                        buttonColor: primaryColor,
                        text: "Cancel Order",
                        textColor: kWhite,
                        function: () {
                          DatabaseService.db
                              .ref()
                              .child("orders")
                              .child(widget.restaurantsKey)
                              .child(orderKeys[index])
                              .remove();
                          DatabaseService.db
                              .ref()
                              .child("cancelled_orders")
                              .child(widget.restaurantsKey)
                              .child(formatter.format(DateTime.now()))
                              .child(orderDetail["phone"])
                              .push()
                              .update({
                            "name": orderDetail["name"],
                            "phone": orderDetail["phone"],
                            "table_name": orderDetail["table_name"],
                            "order_status": "cancelled",
                            "isTableClean": orderDetail["isTableClean"],
                            "waiter": orderDetail["waiter"]
                          });
                        },
                        width: 130,
                        height: 40,
                      ),
                    ],
                  ),
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
