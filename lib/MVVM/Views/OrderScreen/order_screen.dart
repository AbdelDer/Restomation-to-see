import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Repo/Database Service/database_service.dart';
import '../../Repo/Storage Service/storage_service.dart';

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
                return SizedBox(
                    width: double.infinity,
                    child: ExpansionTile(
                      title: CustomText(
                        text: tables[index],
                        fontsize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      subtitle: CustomText(
                        text: "${orderList[index]["name"]}",
                        fontsize: 18,
                      ),
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                (orderList[index]["items"] as Map).length,
                            itemBuilder: (context, itemIndex) {
                              List foodItem = (orderList[index]["items"] as Map)
                                  .values
                                  .toList();
                              return orderItemDisplay(
                                  context, foodItem[itemIndex]);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget orderItemDisplay(BuildContext context, Map data) {
    final ref = StorageService.storage.ref().child(data["image"]);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
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
                "Quantity : ${data["quantity"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
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
              })
        ],
      ),
    );
  }
}
