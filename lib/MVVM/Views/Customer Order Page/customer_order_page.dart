import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

class CustomerOrderPage extends StatelessWidget {
  final String resturantKey;
  const CustomerOrderPage({super.key, required this.resturantKey});

  @override
  Widget build(BuildContext context) {
    Beamer.of(context).beamingHistory.clear();
    return Scaffold(
      appBar: BaseAppBar(
          title: "Table Order",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Column(
        children: [
          const CustomText(text: "My Order"),
          Expanded(
              child: StreamBuilder(
            stream: DatabaseService.db
                .ref()
                .child("resturants")
                .child(resturantKey)
                .child("orders")
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                return Container();
              } else {
                return Container();
              }
            },
          )),
        ],
      ),
    );
  }
}