import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/View%20Model/Order%20View%20Model/order_view_model.dart';
import 'package:restomation/MVVM/Views/OrderScreen/all_waiters_display.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_item_display.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Provider/selected_restaurant_provider.dart';
import '../../../Utils/app_routes.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_alert.dart';
import '../../../Widgets/custom_button.dart';
import '../../Models/Order Model/order_model.dart';
import '../../Models/RestaurantsModel/restaurants_model.dart';
import '../../Repo/Database Service/database_service.dart';
import '../../Repo/Order Service/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({
    super.key,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}


class _OrderScreenState extends State<OrderScreen> {
  List<OrderModel> list = [];
  int count=0;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    RestaurantModel? restaurantModel = context.read<SelectedRestaurantProvider>().restaurantModel;
        return Scaffold(
        appBar: BaseAppBar(
          title: restaurantModel?.name ?? "",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50,
          automaticallyImplyLeading: true,
        ),
        body: Center(
            child: FutureBuilder(
              future: FirebaseFirestore.instance.collection("/restaurants").doc(restaurantModel?.id??"").collection("orders")
                .snapshots().forEach((element) async{
              for (var elements in element.docs) {
                await FirebaseFirestore.instance.collection("/restaurants").doc(restaurantModel?.id??"").collection("orders").doc(elements.id.toString()).collection("order_items").snapshots()
                    .forEach((elemen) async{
                  for(var i in elemen.docs){
                    String name = i['name'].toString();
                    String category = i['category']??"No Provided".toString();
                    String description = i['description'].toString();
                    String price = i['price'].toString();
                    String quantity = i['quantity'].toString();
                    String rating = i['rating'].toString();
                    String reviews = i['reviews'].toString();
                    String status = i['status'].toString();
                    String type = i['type'].toString();
                    String upselling = i['upselling'].toString();
                    String order = i['order'].toString();
                    OrderModel orderModel = OrderModel(
                        name: name,
                        status: status,
                        price: price,
                        description: description,
                        category: category,
                        quantity: quantity,
                        rating: rating,
                        reviews: reviews,
                        type: type,
                        upselling: upselling,
                        order: order
                    );
                    list.add(orderModel);
                    if(count==0){
                      setState(() {
                        count++;
                      });

                    }
                  }
                });
              }
            }),
              builder: (context,  snapshot) {
                return list.length==0?Container(
                  child: Text("NO LIST FOUND"),
                ): Padding(
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
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            // String key = snapshot.data![index] as String;
                            // bool isOpened = false;
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Table Name: "+list[index].name.toString()),
                                        Text("Price: "+list[index].price.toString()),
                                      ],
                                    ),
                                    SizedBox(height: 30,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Text("Rating: "+list[index].rating.toString()),
                                        Text("Status: "+list[index].status.toString()),
                                    ],),
                                    SizedBox(height: 30,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Text("Type: "+list[index].type.toString()),
                                      Text("Reviews: "+list[index].reviews.toString()),
                                    ],),
                                    SizedBox(height: 30,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Description: "+list[index].description.toString()),
                                        Text("Quantity: "+list[index].quantity.toString()),
                                    ],),
                                    SizedBox(height: 30,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Category: "+list[index].category.toString()),
                                        Text("Order: "+list[index].order.toString()),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                            // return listExpansionView(isOpened, snapshot.data!, index,
                            //     (snapshot.data! as Map), restaurantModel);
                          },
                        ),
                      ),
                    ],
                  ),
                );
               // return orderDisplayView( list, restaurantModel!);
                }
                ),
        ));
  }

  Widget orderDisplayView(
       snapshot, RestaurantModel restaurantModel) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.isEmpty) {
      return const Center(
        child: CustomText(text: "No Orders Yet !!"),
      );
    }
    if(snapshot.data!.hasError){
      return Center(child: Text("ERROR"),);
    }
    // Map? order = (snapshot.data as DatabaseEvent).snapshot.value as Map;
    // List orderKeys = order.keys.toList();

    // List<OrderModel> order = snapshot.data!;
    // final suggestions = order.where((element) {
    //   final category = element.category!;
    //   final name = element.name!;
    //   final type = element.type!;
    //   final upselling = element.upselling!;
    //   final status = element.status!;
    //   final quantity = element.quantity!;
    //   final description = element.description!;
    //   final price = element.price!;
    //   final rating = element.rating!;
    //   return true;
    // }).toList();
    // order = suggestions;
          return  Padding(
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
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      String key = snapshot.data![index] as String;
                      bool isOpened = false;
                      return Container(
                        child: Text(list[index].name.toString()),
                      );
                      // return listExpansionView(isOpened, snapshot.data!, index,
                      //     (snapshot.data! as Map), restaurantModel);
                    },
                  ),
                ),
              ],
            ),
          );


  }

  Widget listExpansionView(bool isOpened, List orderKeys, int index,
      Map orderDetail, RestaurantModel restaurantModel) {
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
                        restaurantName: restaurantModel.name ?? "",
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
                                .child(restaurantModel.name ?? "")
                                .child(orderKeys[index])
                                .update({"order_status": "preparing"}).then(
                                    (value) => KRoutes.pop(context));
                          } else if (orderDetail["waiter"] == "none") {
                            showDialog(
                              context: context,
                              builder: (context) => AllWaiterDisplay(
                                restaurantKey: restaurantModel.name ?? "",
                                tableKey: orderKeys[index],
                              ),
                            );
                          } else if (orderDetail["order_status"] ==
                              "delivered") {
                            DatabaseService.db
                                .ref()
                                .child("orders")
                                .child(restaurantModel.name ?? "")
                                .child(orderKeys[index])
                                .remove();
                            DatabaseService.db
                                .ref()
                                .child("completed-orders")
                                .child(restaurantModel.name ?? "")
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
                              .child(restaurantModel.name ?? "")
                              .child(orderKeys[index])
                              .remove();
                          DatabaseService.db
                              .ref()
                              .child("cancelled_orders")
                              .child(restaurantModel.name ?? "")
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
          )
      );
    });
  }

}
