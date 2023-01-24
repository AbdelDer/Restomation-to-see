import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Repo/Order%20Service/order_service.dart';
import 'package:restomation/MVVM/Repo/api_status.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

class PageDecider extends StatefulWidget {
  final String restaurantKey;
  final String tableKey;
  const PageDecider({
    super.key,
    required this.restaurantKey,
    required this.tableKey,
  });

  @override
  State<PageDecider> createState() => _PageDeciderState();
}

class _PageDeciderState extends State<PageDecider> {
  Future<void> checkExistingOrder() async {
    await OrderService()
        .checkExisitingOrder(widget.restaurantKey, widget.tableKey)
        .then((value) {
      if (value is Success) {
        var doc = value.response as QuerySnapshot<Map<String, dynamic>>;
        if (doc.docs.map((e) => e.data()).toList().isNotEmpty) {
          context.replace(
              "/customer-order-page/${widget.restaurantKey},${widget.tableKey}");
          return;
        }
        context.replace(
            "/customer-page/${widget.restaurantKey},${widget.tableKey}");
      }
      if (value is Failure) {}
    });
  }

  @override
  void initState() {
    checkExistingOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "restomation",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            CustomText(text: "checking existing order !!")
          ],
        ),
      ),
    );
  }
}
