import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../Repo/Database Service/database_service.dart';

class PageDecider extends StatefulWidget {
  final String restaurantsKey;
  final String tableKey;
  final String restaurantsImageName;
  const PageDecider(
      {super.key,
      required this.restaurantsKey,
      required this.tableKey,
      required this.restaurantsImageName});

  @override
  State<PageDecider> createState() => _PageDeciderState();
}

class _PageDeciderState extends State<PageDecider> {
  Future<void> checkExistingOrder() async {
    await DatabaseService.db
        .ref("orders")
        .child(widget.restaurantsKey)
        .once()
        .then((value) {
      Map orders = (value.snapshot.value as Map);
      List orderKeys = orders.keys.toList();
      for (var key in orderKeys) {
        orders[key]["table_name"] == widget.tableKey;
        Beamer.of(context).beamToNamed(
            "/customer-order/${widget.restaurantsKey},${widget.tableKey},${orders[key]["name"]},${orders[key]["phone"]}");
        return;
      }
      Beamer.of(context).beamToNamed(
          "/customer-table/${widget.restaurantsKey},${widget.tableKey},${widget.restaurantsImageName}");
    });
  }

  @override
  void initState() {
    checkExistingOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
