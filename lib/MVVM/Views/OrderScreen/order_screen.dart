import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';

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
        itemBuilder: (context, index) => orderCard(),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: allOrders.keys.length);
  }

  Widget orderCard() {
    return Container();
  }
}
