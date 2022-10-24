import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Repo/Storage Service/storage_service.dart';

class OrderScreen extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  const OrderScreen(
      {super.key, required this.resturantKey, required this.resturantName});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Map allOrders = {};
  @override
  void initState() {
    getAllResturantsOrders();
    super.initState();
  }

  getAllResturantsOrders() {
    DatabaseReference ordersCountRef = FirebaseDatabase.instance
        .ref()
        .child("resturants")
        .child(widget.resturantKey)
        .child("orders");
    ordersCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      data as Map?;
      setState(() {
        if (data != null) {
          print(data);
          allOrders = data;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: widget.resturantName,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50,
          automaticallyImplyLeading: true,
        ),
        body: Center(child: orderList()));
  }

  Widget orderList() {
    if (allOrders.keys.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://static.vecteezy.com/system/resources/previews/005/051/242/original/a-man-unpacking-the-paper-box-illustration-concept-flat-illustration-isolated-on-white-background-vector.jpg",
            width: 300,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("No Orders Yet")
        ],
      );
    }
    return ListView.separated(
        itemBuilder: (context, index) => Container(),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: allOrders.keys.length);
  }

  Widget orderCard(int index) {
    Map foodOrder = allOrders.keys.toList()[index];
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 1),
                spreadRadius: 5,
                blurRadius: 5)
          ]),
      child: Column(
        children: [
          CustomText(text: foodOrder["table"]),
          Column(
            children: foodOrder.keys.map((e) {
              if (e != "customer" || e != "table") {
                return orderItemDisplay(context, foodOrder[e]);
              }
              return Container();
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget orderItemDisplay(BuildContext context, Map data) {
    final ref = StorageService.storage.ref().child(data["image"]);
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
                data["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "₹${data["price"]} x ${data["quantity"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                  text:
                      "total  ${double.parse(data["price"]) * data["quantity"]}")
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
        )
      ],
    );
  }
}
